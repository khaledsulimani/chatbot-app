import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/voice_provider.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onVoiceMessage;

  const VoiceInputWidget({
    super.key,
    required this.onVoiceMessage,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  VoiceState? _previousState;

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceProvider>(
      builder: (context, voiceProvider, child) {
        // Check if voice recognition just stopped and process the input
        if (_previousState == VoiceState.listening && 
            voiceProvider.state == VoiceState.idle &&
            voiceProvider.recognizedText.trim().isNotEmpty) {
          // Use a post-frame callback to avoid calling setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _processVoiceInput(voiceProvider);
          });
        }
        _previousState = voiceProvider.state;

        return GestureDetector(
          onTap: () => _handleVoiceInput(voiceProvider),
          onLongPress: () => _handleVoiceInput(voiceProvider),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getButtonColor(context, voiceProvider),
              boxShadow: [
                BoxShadow(
                  color: _getButtonColor(context, voiceProvider).withOpacity(0.3),
                  blurRadius: voiceProvider.isListening ? 20 : 8,
                  spreadRadius: voiceProvider.isListening ? 2 : 0,
                ),
              ],
            ),
            child: _buildButtonContent(context, voiceProvider),
          ),
        ).animate(target: voiceProvider.isListening ? 1 : 0)
            .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
            .then()
            .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1));
      },
    );
  }

  Widget _buildButtonContent(BuildContext context, VoiceProvider voiceProvider) {
    final theme = Theme.of(context);
    
    if (voiceProvider.isListening) {
      return Icon(
        Icons.mic,
        color: theme.colorScheme.onPrimary,
        size: 28,
      ).animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.5));
    } else if (voiceProvider.isSpeaking) {
      return Icon(
        Icons.volume_up,
        color: theme.colorScheme.onSecondary,
        size: 28,
      );
    } else if (voiceProvider.isProcessing) {
      return SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.onPrimary,
          ),
        ),
      );
    } else {
      return Icon(
        voiceProvider.speechEnabled ? Icons.mic_outlined : Icons.mic_off,
        color: voiceProvider.speechEnabled 
            ? theme.colorScheme.onPrimary 
            : theme.colorScheme.onSurface.withOpacity(0.5),
        size: 28,
      );
    }
  }

  Color _getButtonColor(BuildContext context, VoiceProvider voiceProvider) {
    final theme = Theme.of(context);
    
    if (voiceProvider.isListening) {
      return theme.colorScheme.primary;
    } else if (voiceProvider.isSpeaking) {
      return theme.colorScheme.secondary;
    } else if (voiceProvider.speechEnabled) {
      return theme.colorScheme.primaryContainer;
    } else {
      return theme.colorScheme.surface;
    }
  }

  Future<void> _handleVoiceInput(VoiceProvider voiceProvider) async {
    if (!voiceProvider.isInitialized) {
      _showError(context, 'Voice services are not initialized');
      return;
    }

    if (!voiceProvider.speechEnabled) {
      _showError(context, 'Speech recognition is not available');
      return;
    }

    if (voiceProvider.isListening) {
      await voiceProvider.stopListening();
      _processVoiceInput(voiceProvider);
    } else if (voiceProvider.isSpeaking) {
      await voiceProvider.stopSpeaking();
    } else {
      voiceProvider.clearRecognizedText();
      await voiceProvider.startListening();
    }
  }

  void _processVoiceInput(VoiceProvider voiceProvider) {
    final recognizedText = voiceProvider.recognizedText.trim();
    
    print('DEBUG: Processing voice input: "$recognizedText"'); // Debug line
    
    if (recognizedText.isNotEmpty) {
      print('DEBUG: Calling onVoiceMessage with: "$recognizedText"'); // Debug line
      widget.onVoiceMessage(recognizedText);
      voiceProvider.clearRecognizedText();
      
      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice message: "$recognizedText"'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      print('DEBUG: No speech detected'); // Debug line
      _showError(context, 'No speech detected. Please try again.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

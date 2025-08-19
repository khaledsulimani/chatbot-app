import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/chat_provider.dart';
import '../providers/voice_provider.dart';
import '../models/chat_message.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/voice_input_widget.dart';
import '../widgets/text_input_widget.dart';
import '../widgets/voice_visualization_widget.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  String? _lastAssistantMessageId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      if (!chatProvider.hasMessages) {
        chatProvider.addWelcomeMessage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<VoiceProvider>(
          builder: (context, voiceProvider, child) {
            return Column(
              children: [
                Text(
                  'Nada - AI Voice Assistant',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (voiceProvider.isListening)
                  Text(
                    'Listening...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(duration: 600.ms)
                      .fadeOut(duration: 600.ms),
              ],
            );
          },
        ),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              // Check for new AI responses to voice messages and speak them
              final messages = chatProvider.messages;
              if (messages.isNotEmpty) {
                final lastMessage = messages.last;
                if (lastMessage.type == MessageType.assistant && 
                    lastMessage.id != _lastAssistantMessageId) {
                  _lastAssistantMessageId = lastMessage.id;
                  
                  // Check if the previous message was a voice message
                  if (messages.length >= 2) {
                    final previousMessage = messages[messages.length - 2];
                    if (previousMessage.type == MessageType.user && previousMessage.isAudio) {
                      // Auto-speak the AI response
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _speakMessage(context, lastMessage.content);
                      });
                    }
                  }
                }
              }

              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: chatProvider.hasMessages 
                    ? () => _showClearDialog(context, chatProvider)
                    : null,
                tooltip: 'Clear chat',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsDialog(context),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Voice visualization
          Consumer<VoiceProvider>(
            builder: (context, voiceProvider, child) {
              if (voiceProvider.isListening) {
                return Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const VoiceVisualizationWidget(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Chat messages
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return ChatMessageWidget(
                      message: message,
                      onSpeak: (text) => _speakMessage(context, text),
                    ).animate()
                        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                );
              },
            ),
          ),

          // Error message
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.error != null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          chatProvider.error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => chatProvider.retryLastMessage(),
                        tooltip: 'Retry',
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextInputWidget(
                      controller: _textController,
                      onSendMessage: (message) {
                        _sendTextMessage(context, message);
                        _scrollToBottom();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  VoiceInputWidget(
                    onVoiceMessage: (message) {
                      _sendVoiceMessage(context, message);
                      _scrollToBottom();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendTextMessage(BuildContext context, String message) {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage(message, isVoice: false);
    _textController.clear();
  }

  void _sendVoiceMessage(BuildContext context, String message) {
    print('DEBUG: _sendVoiceMessage called with: "$message"'); // Debug line
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage(message, isVoice: true);
  }

  void _speakMessage(BuildContext context, String text) {
    final voiceProvider = context.read<VoiceProvider>();
    voiceProvider.speak(text);
  }

  void _showClearDialog(BuildContext context, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              chatProvider.clearMessages();
              chatProvider.addWelcomeMessage();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Settings'),
        content: Consumer<VoiceProvider>(
          builder: (context, voiceProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (voiceProvider.availableVoices.isNotEmpty) ...[
                  const Text('Select Voice:'),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: voiceProvider.selectedVoice,
                    isExpanded: true,
                    items: voiceProvider.availableVoices.map((voice) {
                      return DropdownMenuItem(
                        value: voice,
                        child: Text(voice),
                      );
                    }).toList(),
                    onChanged: (voice) {
                      if (voice != null) {
                        voiceProvider.setVoice(voice);
                      }
                    },
                  ),
                ] else
                  const Text('No voices available'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

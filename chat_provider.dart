import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final AIService _aiService = AIService();
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMessages => _messages.isNotEmpty;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void updateMessage(String messageId, ChatMessage updatedMessage) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content, {bool isVoice = false}) async {
    if (content.trim().isEmpty) return;

    print('DEBUG: Sending message: "$content", isVoice: $isVoice'); // Debug line
    _setError(null);
    
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
      isAudio: isVoice,
    );
    
    print('DEBUG: Adding user message: ${userMessage.toString()}'); // Debug line
    addMessage(userMessage);
    _setLoading(true);

    try {
      // Get AI response
      print('DEBUG: Getting AI response for: "${content.trim()}"'); // Debug line
      final response = await _aiService.getResponse(content.trim());
      
      print('DEBUG: Got AI response: "$response"'); // Debug line
      
      // Add assistant message
      final assistantMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: response,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
      
      print('DEBUG: Adding assistant message: ${assistantMessage.toString()}'); // Debug line
      addMessage(assistantMessage);
      
      // Auto-speak AI responses if the original message was voice
      if (isVoice) {
        // We'll need to trigger TTS here - this will be handled by the UI
        notifyListeners(); // Extra notification to ensure UI updates
      }
    } catch (e) {
      _setError('Failed to get response: ${e.toString()}');
      
      // Add error message
      final errorMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        type: MessageType.system,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      );
      
      addMessage(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  void clearMessages() {
    _messages.clear();
    _setError(null);
    notifyListeners();
  }

  void deleteMessage(String messageId) {
    _messages.removeWhere((msg) => msg.id == messageId);
    notifyListeners();
  }

  void retryLastMessage() {
    if (_messages.isNotEmpty) {
      final lastUserMessage = _messages
          .lastWhere(
            (msg) => msg.type == MessageType.user,
            orElse: () => throw StateError('No user message found'),
          );
      
      // Remove messages after the last user message
      final lastUserIndex = _messages.indexOf(lastUserMessage);
      _messages.removeRange(lastUserIndex + 1, _messages.length);
      
      // Resend the message
      sendMessage(lastUserMessage.content, isVoice: lastUserMessage.isAudio);
    }
  }

  List<ChatMessage> getMessagesByType(MessageType type) {
    return _messages.where((msg) => msg.type == type).toList();
  }

  ChatMessage? getMessageById(String id) {
    try {
      return _messages.firstWhere((msg) => msg.id == id);
    } catch (e) {
      return null;
    }
  }

  void addSystemMessage(String content) {
    final systemMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.system,
      timestamp: DateTime.now(),
    );
    
    addMessage(systemMessage);
  }

  void addWelcomeMessage() {
    addSystemMessage(
      'Welcome! I\'m Nada, your AI Voice Assistant! 👋\n\n'
      'Created by Engineer Khaled Sulaimani\n\n'
      'I can help you with:\n'
      '• Answering questions on various topics\n'
      '• Having natural conversations\n'
      '• Voice commands - just tap the microphone to speak\n'
      '• Math calculations and problem-solving\n\n'
      'How can I assist you today?'
    );
  }
}

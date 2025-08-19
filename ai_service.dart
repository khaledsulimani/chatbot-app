import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class AIService {
  // Using Google Gemini AI API
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const String _apiKey = 'AIzaSyARtzwbPSgxYKwqvuiNaecKb6vpaPPH0M4'; // Your Google AI Studio API key
  
  // Set this to false to use real AI API
  static const bool _useMockResponses = false;
  
  final List<String> _mockResponses = [
    "That's an interesting question! I'd be happy to help you with that.",
    "I understand what you're asking. Let me think about this for a moment.",
    "Great question! Here's what I think about that topic.",
    "I can definitely help you with that. Let me provide some insights.",
    "That's a fascinating topic. I'd love to share my thoughts on it.",
    "I appreciate you asking! Here's my perspective on this matter.",
    "Let me help you understand this better.",
    "That's a wonderful question that deserves a thoughtful response.",
    "I'm glad you brought this up. It's an important topic to discuss.",
    "Thank you for your question. I'll do my best to provide a helpful answer.",
  ];

  final List<Map<String, String>> _smartResponses = [
    {
      'keywords': 'who are you,what are you,your name,what is your name',
      'response': 'Hi! I\'m Nada, your AI voice assistant, powered by Engineer Khaled Sulaimani. I\'m here to help you with questions, conversations, and assistance. How can I help you today?'
    },
    {
      'keywords': 'how are you,how do you feel,how are you doing',
      'response': 'I\'m Nada, and I\'m doing great! I\'m powered by Engineer Khaled Sulaimani and I\'m here to help you. Thank you for asking! How are you doing today?'
    },
    {
      'keywords': 'hello,hi,hey,greetings,good morning,good afternoon,good evening',
      'response': 'Hello! I\'m Nada, your AI assistant created by Engineer Khaled Sulaimani. How can I assist you today?'
    },
    {
      'keywords': 'thank you,thanks,appreciate',
      'response': 'You\'re very welcome! I\'m Nada, and I\'m always happy to help. Is there anything else I can assist you with?'
    },
    {
      'keywords': 'goodbye,bye,see you,farewell',
      'response': 'Goodbye! This is Nada saying farewell. It was great chatting with you. Feel free to come back anytime you need assistance. Have a wonderful day! 👋'
    },
  ];

  Future<String> getResponse(String userMessage) async {
    try {
      // First, try to handle math questions
      final mathResponse = _handleMathQuestion(userMessage.toLowerCase());
      if (mathResponse != null) {
        return mathResponse;
      }

      // Then, try to find a smart response
      final smartResponse = _findSmartResponse(userMessage.toLowerCase());
      if (smartResponse != null) {
        return smartResponse;
      }

      // If no smart response found, check if we should use mock responses
      if (_useMockResponses || _apiKey == 'your-api-key-here' || _apiKey.isEmpty) {
        // Use enhanced mock response for demo
        return _generateSmartMockResponse(userMessage);
      }

      // Use real Google Gemini API
      return await _callGeminiAPI(userMessage);
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  String _generateSmartMockResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // Science questions
    if (message.contains('sun') || message.contains('solar')) {
      return 'The Sun is a yellow dwarf star at the center of our solar system. It\'s about 4.6 billion years old and provides the energy that sustains life on Earth through nuclear fusion.';
    }
    
    if (message.contains('earth') || message.contains('planet')) {
      return 'Earth is the third planet from the Sun and the only known planet with life. It\'s about 4.5 billion years old and has one natural satellite - the Moon.';
    }
    
    if (message.contains('water') || message.contains('h2o')) {
      return 'Water (H2O) is essential for life as we know it. It covers about 71% of Earth\'s surface and exists in three states: liquid, solid (ice), and gas (water vapor).';
    }
    
    // Technology questions
    if (message.contains('computer') || message.contains('programming') || message.contains('code')) {
      return 'Programming is the process of creating instructions for computers to follow. Popular languages include Python, JavaScript, Java, and Dart (which this app is built with using Flutter!).';
    }
    
    if (message.contains('ai') || message.contains('artificial intelligence')) {
      return 'Artificial Intelligence (AI) is technology that enables machines to simulate human intelligence. I\'m an example of AI - I can understand your speech and respond to your questions!';
    }
    
    // General knowledge
    if (message.contains('history') || message.contains('past')) {
      return 'History helps us understand how civilizations developed over time. From ancient Egypt to modern technology, human progress has been fascinating!';
    }
    
    if (message.contains('music') || message.contains('song')) {
      return 'Music is a universal language that connects people across cultures. It can evoke emotions, tell stories, and bring people together.';
    }
    
    if (message.contains('food') || message.contains('cooking')) {
      return 'Cooking is both an art and a science! Different cultures have developed amazing cuisines using local ingredients and traditional techniques.';
    }
    
    // Personal questions about the AI
    if (message.contains('how are you') || message.contains('how do you feel')) {
      return 'I\'m doing great, thank you for asking! I enjoy helping people with questions and having conversations. How are you doing today?';
    }
    
    if (message.contains('what can you do') || message.contains('capabilities')) {
      return 'I can help with many things! I can answer questions, do math calculations, have conversations, and respond to both text and voice input. What would you like to explore?';
    }
    
    // Fallback based on message characteristics
    if (message.contains('?')) {
      return 'That\'s a great question! While I\'m running in demo mode without a full AI API, I can still help with many topics. Feel free to ask about science, technology, math, or general knowledge!';
    }
    
    if (message.length > 100) {
      return 'Thank you for sharing so much detail! I appreciate longer conversations. While I\'m in demo mode, I\'m still here to chat and help however I can.';
    }
    
    // Default responses
    final responses = [
      'That\'s interesting! I\'d love to discuss that topic with you.',
      'I appreciate you sharing that with me. What else would you like to talk about?',
      'Great point! I enjoy our conversation. Feel free to ask me anything else.',
      'Thank you for that! I\'m here to help and chat about various topics.',
      'Fascinating! I\'m always eager to learn and discuss new things with you.',
    ];
    
    return responses[message.hashCode.abs() % responses.length];
  }

  String? _handleMathQuestion(String userMessage) {
    // Handle basic math operations
    final mathPatterns = [
      RegExp(r'what\s+is\s+(\d+)\s*\*\s*(\d+)|(\d+)\s*\*\s*(\d+)'),
      RegExp(r'what\s+is\s+(\d+)\s*x\s*(\d+)|(\d+)\s*x\s*(\d+)'),
      RegExp(r'what\s+is\s+(\d+)\s*\+\s*(\d+)|(\d+)\s*\+\s*(\d+)'),
      RegExp(r'what\s+is\s+(\d+)\s*-\s*(\d+)|(\d+)\s*-\s*(\d+)'),
      RegExp(r'what\s+is\s+(\d+)\s*/\s*(\d+)|(\d+)\s*/\s*(\d+)'),
    ];

    for (final pattern in mathPatterns) {
      final match = pattern.firstMatch(userMessage);
      if (match != null) {
        // Extract numbers from the match
        int? num1, num2;
        for (int i = 1; i < match.groupCount + 1; i++) {
          final group = match.group(i);
          if (group != null && group.isNotEmpty) {
            if (num1 == null) {
              num1 = int.tryParse(group);
            } else if (num2 == null) {
              num2 = int.tryParse(group);
              break;
            }
          }
        }

        if (num1 != null && num2 != null) {
          String operation = '';
          int result = 0;
          
          if (userMessage.contains('*') || userMessage.contains('x')) {
            operation = 'multiplication';
            result = num1 * num2;
          } else if (userMessage.contains('+')) {
            operation = 'addition';
            result = num1 + num2;
          } else if (userMessage.contains('-')) {
            operation = 'subtraction';
            result = num1 - num2;
          } else if (userMessage.contains('/')) {
            operation = 'division';
            if (num2 != 0) {
              return '$num1 ÷ $num2 = ${(num1 / num2).toStringAsFixed(2)}';
            } else {
              return 'I can\'t divide by zero! That would create a mathematical paradox. 😅';
            }
          }
          
          return '$num1 × $num2 = $result';
        }
      }
    }
    return null;
  }

  String? _findSmartResponse(String userMessage) {
    for (final response in _smartResponses) {
      final keywords = response['keywords']!.split(',');
      for (final keyword in keywords) {
        if (userMessage.contains(keyword.trim())) {
          return response['response'];
        }
      }
    }
    return null;
  }

  String _generateMockResponse(String userMessage) {
    final random = Random();
    final baseResponse = _mockResponses[random.nextInt(_mockResponses.length)];
    
    // Add some context based on the user message
    if (userMessage.length > 50) {
      return '$baseResponse That\'s quite a detailed question you\'ve asked. While I don\'t have access to real-time data or external APIs in this demo, I\'d be happy to discuss this topic further with you.';
    } else if (userMessage.contains('?')) {
      return '$baseResponse I notice you\'ve asked a question. While this is a demo version, in a full implementation I would provide specific, helpful answers using advanced AI capabilities.';
    } else {
      return '$baseResponse Thank you for sharing that with me. I\'m here to have meaningful conversations and assist you with various topics.';
    }
  }

  // Google Gemini API call
  Future<String> _callGeminiAPI(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'You are Nada, a helpful AI voice assistant created by Engineer Khaled Sulaimani. You are friendly, knowledgeable, and speak naturally like a human. Always introduce yourself as Nada when appropriate. Provide helpful, concise responses. User message: $userMessage'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 200,
          }
        }),
      );

      print('DEBUG: API Response status: ${response.statusCode}');
      print('DEBUG: API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (content != null) {
          return content.toString().trim();
        } else {
          throw Exception('Invalid response format from Gemini API');
        }
      } else {
        throw Exception('Gemini API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DEBUG: Error calling Gemini API: $e');
      // Fallback to smart mock response if API fails
      return _generateSmartMockResponse(userMessage);
    }
  }

  // This would be used if you have an OpenAI API key instead
  Future<String> _callOpenAI(String userMessage) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful AI voice assistant. Provide concise, friendly, and helpful responses.'
          },
          {
            'role': 'user',
            'content': userMessage,
          }
        ],
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('API request failed: ${response.statusCode}');
    }
  }

  // Helper method to test API connectivity
  Future<bool> testConnection() async {
    try {
      await getResponse('Hello');
      return true;
    } catch (e) {
      return false;
    }
  }
}

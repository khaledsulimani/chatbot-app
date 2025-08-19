# AI Voice Assistant 🎤🤖

An intelligent Flutter-based voice assistant application with advanced speech recognition, text-to-speech capabilities, and a beautiful modern UI. This app provides a seamless conversational experience through both voice and text interactions.

## ✨ Features

### 🎙️ Voice Capabilities
- **Speech-to-Text**: Advanced speech recognition with real-time feedback
- **Text-to-Speech**: Natural voice responses with customizable voices
- **Voice Visualization**: Beautiful animated waveforms during voice input
- **Hands-free Experience**: Complete voice-driven interaction

### 💬 Chat Interface
- **Modern UI**: Clean, intuitive chat interface with Material Design 3
- **Animated Responses**: Typewriter-style animations for AI responses
- **Message Management**: Copy, speak, and manage chat messages
- **Smart Responses**: Context-aware AI responses with intelligent fallbacks

### 🎨 User Experience
- **Dark/Light Theme**: Automatic theme switching based on system preferences
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Responsive Design**: Optimized for various screen sizes
- **Accessibility**: Full support for screen readers and accessibility features

### 🧠 AI Integration
- **Smart Response System**: Intelligent responses based on context and keywords
- **Extensible AI Backend**: Ready for integration with OpenAI, Gemini, or custom APIs
- **Error Handling**: Graceful error handling with retry mechanisms
- **Offline Support**: Basic functionality available without internet connection

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (^3.8.1)
- **Dart SDK** (latest)
- **Android Studio** or **VS Code** with Flutter extensions
- **Physical device** or emulator (microphone access required for voice features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/my_voice_assistant.git
   cd my_voice_assistant
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure permissions** (Android)
   - Microphone permission is automatically requested
   - Internet permission for AI API calls

4. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Usage

### Voice Interaction
1. **Tap the microphone button** to start voice recognition
2. **Speak your question** or command
3. **Watch the voice visualization** while speaking
4. **Receive AI response** both as text and optional voice output

### Text Interaction
1. **Type your message** in the text input field
2. **Press send** or hit enter
3. **View animated responses** from the AI assistant

### Additional Features
- **Clear chat**: Remove all messages and start fresh
- **Voice settings**: Choose from available system voices
- **Copy messages**: Long-press to copy AI responses
- **Speak responses**: Tap the speaker icon to hear any message

## 🛠️ Technology Stack

### Framework & Language
- **Flutter** - Cross-platform app development
- **Dart** - Programming language

### Voice & Audio
- **speech_to_text** (^7.0.0) - Speech recognition
- **flutter_tts** (^4.1.0) - Text-to-speech synthesis
- **audioplayers** (^6.1.0) - Audio playback capabilities

### State Management & UI
- **Provider** (^6.1.2) - State management
- **animated_text_kit** (^4.2.2) - Text animations
- **flutter_animate** (^4.5.0) - Advanced animations

### Networking & Permissions
- **http** (^1.2.1) - API communication
- **permission_handler** (^11.3.1) - Runtime permissions

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── chat_message.dart    # Message model with types and status
├── providers/               # State management
│   ├── chat_provider.dart   # Chat state and message handling
│   └── voice_provider.dart  # Voice recognition and TTS
├── screens/                 # UI screens
│   └── voice_assistant_screen.dart  # Main chat interface
├── services/                # Business logic
│   └── ai_service.dart      # AI response generation
└── widgets/                 # Reusable UI components
    ├── chat_message_widget.dart     # Individual message display
    ├── text_input_widget.dart       # Text input component
    ├── voice_input_widget.dart      # Voice input button
    └── voice_visualization_widget.dart  # Voice animation
```

### Key Components

#### VoiceProvider
Manages all voice-related functionality:
- Speech recognition lifecycle
- Text-to-speech operations
- Voice settings and configuration
- Permission handling

#### ChatProvider
Handles chat state and messaging:
- Message management and storage
- AI response coordination
- Error handling and retry logic
- Message type classification

#### AIService
Provides intelligent responses:
- Smart keyword-based responses
- Mock response generation
- API integration ready
- Context-aware fallbacks

## 🔧 Customization

### Adding Your Own AI Backend

Replace the mock responses in `ai_service.dart`:

```dart
// Replace with your preferred AI service
Future<String> _callOpenAI(String userMessage) async {
  // Your API implementation here
}
```

### Customizing Voice Settings

Modify voice parameters in `voice_provider.dart`:

```dart
await _flutterTts.setSpeechRate(0.5);  // Adjust speech rate
await _flutterTts.setPitch(1.0);       // Adjust pitch
await _flutterTts.setLanguage('en-US'); // Set language
```

### UI Theming

Update theme settings in `main.dart`:

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.blue,  // Change primary color
  brightness: Brightness.light,
),
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Speech-to-text and TTS plugin contributors
- Material Design team for the beautiful design system
- Open source community for inspiration and support

## 📞 Support

If you have any questions or need help with the project:

- Create an issue on GitHub
- Check the [Flutter documentation](https://flutter.dev/docs)
- Visit [Flutter community](https://flutter.dev/community)

---

**Made with ❤️ using Flutter**

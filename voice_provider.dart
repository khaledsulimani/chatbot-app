import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

enum VoiceState { idle, listening, speaking, processing }

class VoiceProvider extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  VoiceState _state = VoiceState.idle;
  String _recognizedText = '';
  bool _isInitialized = false;
  bool _speechEnabled = false;
  double _confidence = 0.0;
  List<String> _availableVoices = [];
  String? _selectedVoice;

  // Getters
  VoiceState get state => _state;
  String get recognizedText => _recognizedText;
  bool get isInitialized => _isInitialized;
  bool get speechEnabled => _speechEnabled;
  double get confidence => _confidence;
  List<String> get availableVoices => _availableVoices;
  String? get selectedVoice => _selectedVoice;
  
  bool get isListening => _state == VoiceState.listening;
  bool get isSpeaking => _state == VoiceState.speaking;
  bool get isProcessing => _state == VoiceState.processing;

  VoiceProvider() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _initializeSpeechToText();
      await _initializeTextToSpeech();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing voice services: $e');
      // For web, we'll mark as initialized even if some features don't work
      if (kIsWeb) {
        _isInitialized = true;
        notifyListeners();
      }
    }
  }

  Future<void> _initializeSpeechToText() async {
    try {
      // On web, permission handling is different
      if (kIsWeb) {
        _speechEnabled = await _speechToText.initialize(
          onError: (error) {
            debugPrint('Speech recognition error: $error');
            _setState(VoiceState.idle);
          },
          onStatus: (status) {
            debugPrint('Speech recognition status: $status');
            if (status == 'done' || status == 'notListening') {
              _setState(VoiceState.idle);
            }
          },
        );
      } else {
        // Request microphone permission for mobile
        final status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          debugPrint('Microphone permission denied');
          return;
        }

        _speechEnabled = await _speechToText.initialize(
          onError: (error) {
            debugPrint('Speech recognition error: $error');
            _setState(VoiceState.idle);
          },
          onStatus: (status) {
            debugPrint('Speech recognition status: $status');
            if (status == 'done' || status == 'notListening') {
              _setState(VoiceState.idle);
            }
          },
        );
      }
      
      debugPrint('Speech recognition initialized: $_speechEnabled');
    } catch (e) {
      debugPrint('Error initializing speech to text: $e');
      _speechEnabled = false;
    }
  }

  Future<void> _initializeTextToSpeech() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.8); // More natural speaking speed
      await _flutterTts.setVolume(1.0);

      // Get available voices (might not work on web)
      try {
        final voices = await _flutterTts.getVoices;
        if (voices is List) {
          _availableVoices = voices
              .where((voice) => voice['locale'].toString().startsWith('en'))
              .map((voice) => voice['name'].toString())
              .toList();
          
          if (_availableVoices.isNotEmpty) {
            _selectedVoice = _availableVoices.first;
            await _flutterTts.setVoice({'name': _selectedVoice!, 'locale': 'en-US'});
          }
        }
      } catch (e) {
        debugPrint('Could not get voices (normal on web): $e');
        // On web, voices might not be available the same way
        if (kIsWeb) {
          _availableVoices = ['Default Web Voice'];
          _selectedVoice = 'Default Web Voice';
        }
      }

      _flutterTts.setStartHandler(() {
        _setState(VoiceState.speaking);
      });

      _flutterTts.setCompletionHandler(() {
        _setState(VoiceState.idle);
      });

      _flutterTts.setErrorHandler((message) {
        debugPrint('TTS Error: $message');
        _setState(VoiceState.idle);
      });

      debugPrint('Text to speech initialized successfully');
    } catch (e) {
      debugPrint('Error initializing text to speech: $e');
    }
  }

  Future<void> startListening() async {
    if (!_speechEnabled || _state != VoiceState.idle) return;

    try {
      _setState(VoiceState.listening);
      _recognizedText = '';
      _confidence = 0.0;
      
      await _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          _confidence = result.confidence;
          print('DEBUG: Speech recognized: "${result.recognizedWords}", confidence: ${result.confidence}'); // Debug line
          notifyListeners();
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      _setState(VoiceState.idle);
    }
  }

  Future<void> stopListening() async {
    if (_state == VoiceState.listening) {
      await _speechToText.stop();
      _setState(VoiceState.idle);
    }
  }

  Future<void> speak(String text) async {
    if (_state == VoiceState.speaking) {
      await _flutterTts.stop();
    }

    try {
      _setState(VoiceState.speaking);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error speaking text: $e');
      _setState(VoiceState.idle);
    }
  }

  Future<void> stopSpeaking() async {
    if (_state == VoiceState.speaking) {
      await _flutterTts.stop();
      _setState(VoiceState.idle);
    }
  }

  Future<void> setVoice(String voiceName) async {
    try {
      _selectedVoice = voiceName;
      await _flutterTts.setVoice({'name': voiceName, 'locale': 'en-US'});
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting voice: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.1, 2.0));
    } catch (e) {
      debugPrint('Error setting speech rate: $e');
    }
  }

  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
    } catch (e) {
      debugPrint('Error setting pitch: $e');
    }
  }

  void _setState(VoiceState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void clearRecognizedText() {
    _recognizedText = '';
    _confidence = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}

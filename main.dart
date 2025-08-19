import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/voice_assistant_screen.dart';
import 'providers/chat_provider.dart';
import 'providers/voice_provider.dart';

void main() {
  runApp(const MyVoiceAssistantApp());
}

class MyVoiceAssistantApp extends StatelessWidget {
  const MyVoiceAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => VoiceProvider()),
      ],
      child: MaterialApp(
        title: 'AI Voice Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const VoiceAssistantScreen(),
      ),
    );
  }
}

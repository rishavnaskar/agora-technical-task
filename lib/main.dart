import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fourleggedlove/functions/auth/auth_handler.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await StreamingSharedPreferences.instance;
  runApp(MyApp(preferences: preferences));
}

class MyApp extends StatelessWidget {
  MyApp({required this.preferences});
  final StreamingSharedPreferences preferences;
  final AuthHandler _authHandler = AuthHandler();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agora Technical Task',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _authHandler.handleAuth(preferences),
    );
  }
}

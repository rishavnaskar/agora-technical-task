import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fourleggedlove/ui/auth/authscreen.dart';
import 'package:fourleggedlove/ui/home/homescreen.dart';

class AuthHandler {
  handleAuth() => StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return AuthScreen();
          if (snapshot.hasError) return AuthScreen();
          if (snapshot.hasData) return HomeScreen();
          return AuthScreen();
        },
      );
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fourleggedlove/ui/auth/authscreen.dart';
import 'package:fourleggedlove/ui/auth/edit_profile.dart';
import 'package:fourleggedlove/ui/home/homescreen.dart';
import 'package:fourleggedlove/utils/constants.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class AuthHandler {
  Widget handleAuth(StreamingSharedPreferences preferences) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return AuthScreen();
        if (snapshot.hasError) return AuthScreen();
        if (snapshot.hasData)
          return PreferenceBuilder<bool>(
            preference:
                preferences.getBool(profileVisited, defaultValue: false),
            builder: (context, val) {
              if (val)
                return HomeScreen();
              else
                return EditProfile();
            },
          );
        return AuthScreen();
      },
    );
  }
}

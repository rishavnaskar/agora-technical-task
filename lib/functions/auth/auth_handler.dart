import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fourleggedlove/ui/auth/authscreen.dart';
import 'package:fourleggedlove/ui/auth/edit_profile.dart';
import 'package:fourleggedlove/ui/home/homescreen.dart';
import 'package:fourleggedlove/ui/utils/error.dart';
import 'package:fourleggedlove/ui/utils/loading.dart';
import 'package:fourleggedlove/utils/constants.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class AuthHandler {
  Widget handleAuth(StreamingSharedPreferences preferences) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return AuthScreen();
        if (snapshot.hasError) return ErrorScreen();
        if (snapshot.hasData)
          return PreferenceBuilder<int>(
            preference: preferences.getInt(profileVisited, defaultValue: -1),
            builder: (context, val) {
              if (val == 1) return HomeScreen();
              if (val == 0)
                return EditProfile();
              else
                return LoadingScreen();
            },
          );
        return AuthScreen();
      },
    );
  }
}

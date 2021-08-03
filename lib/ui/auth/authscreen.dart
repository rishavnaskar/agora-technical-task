import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:fourleggedlove/functions/auth/google_auth.dart';
import 'package:fourleggedlove/utils/common.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final Common _common = Common();
  final GoogleAuth _googleAuth = GoogleAuth();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: _common.background,
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        progressIndicator: _common.progressIndicator(),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.only(top: 50, bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppName(common: _common, fontSize: 40),
                Lottie.asset(
                  "assets/auth.json",
                  fit: BoxFit.contain,
                  height: height * 0.5,
                ),
                SignInButton(
                  Buttons.Google,
                  onPressed: () {
                    setState(() => _isLoading = true);
                    _googleAuth
                        .signInWithGoogle()
                        .then((value) => _googleAuth.signInUser());
                  },
                  elevation: 10,
                  padding: EdgeInsets.only(left: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

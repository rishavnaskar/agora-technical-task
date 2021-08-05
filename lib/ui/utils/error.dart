import 'package:flutter/material.dart';
import 'package:fourleggedlove/utils/common.dart';
import 'package:lottie/lottie.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  final Common _common = Common();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _common.background,
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Please try again after sometime",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Nexa",
                  fontWeight: FontWeight.w600,
                  color: _common.purple,
                  fontSize: 30,
                ),
              ),
              Lottie.asset(
                "assets/error.json",
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

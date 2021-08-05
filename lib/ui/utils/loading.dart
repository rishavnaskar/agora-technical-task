import 'package:flutter/material.dart';
import 'package:fourleggedlove/utils/common.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final Common _common = Common();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _common.background,
      body: SafeArea(
        child: Center(
          child: Lottie.asset(
            "assets/loading.json",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

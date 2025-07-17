import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:master_circolife_app/presentation/auth_screen.dart';
import '../../main.dart';
import '../home/screens/home_screen.dart';
// import '../main.dart';
import 'dart:developer';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? isOnBoardingScreenLaunch;
  String? token;
  String? userid;

  @override
  void initState() {
    login();
    super.initState();
  }

  login() async {
    await _navigationToLoginScreen();
  }

  _navigationToLoginScreen() async {
    await Future.delayed(const Duration(milliseconds: 2000), () {});
    token = await appStorage?.retrieveEncryptedData('token');
    log(token.toString(), name: "Token>");
    if (mounted) {
      (token != null)
          ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()))
          : Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo/new_revamp_logo.png",
              width: 256.09175,
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // checkLogin();
    login();
    // _navigationToLoginScreen();
    super.initState();
  }

  login() async {
    await checkLogin();
  }

  Future<void> checkLogin() async {
    WidgetsBinding.instance.addPostFrameCallback((_){

    User? user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      // log(_isConnected.toString(), name: "INTERNET 3 >>>>");
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    }

    });
    // await checkConnectivity();
  }

  _navigationToLoginScreen() async {
    await Future.delayed(const Duration(milliseconds: 2000), () {});
    token = await appStorage?.retrieveEncryptedData('token');
    log(token.toString(), name: "Token>");
    if (mounted) {
      (token != null)
          ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()))
          : Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("SPLASH")
            // Image.asset(
            //   "assets/images/logo/new_revamp_logo.png",
            //   width: 256.09175,
            // )
          ],
        ),
      ),
    );
  }
}

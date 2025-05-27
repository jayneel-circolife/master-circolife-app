import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:master_circolife_app/presentation/auth/email_otp_screen.dart';
import 'package:master_circolife_app/presentation/auth/otp_screen.dart';
import 'package:master_circolife_app/utils/secrets.dart';
import 'package:master_circolife_app/widgets/email_text_field.dart';
import 'package:http/http.dart' as http;

import '../../widgets/button_styles.dart';
import '../../widgets/number_text_field.dart';
import '../main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController emailController = TextEditingController();
  int numberLength = 0;
  bool isLoading = false;
  String verificationId = "";

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      setState(() {
        numberLength = emailController.text.length;
      });
    });
  }

  Future<Map<String, String>> _getHeaderConfig() async {
    String? token = await appStorage?.retrieveEncryptedData('token');
    Map<String, String> headers = {};
    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers.putIfAbsent("Authorization", () => token);
    }
    return headers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Enter your email", style: TextStyle(fontSize: 24, color: Colors.grey.shade900, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "OTP will be sent to this email",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  EmailTextField(
                    emailController: emailController,
                  )
                ],
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () async {
                      dev.log(numberLength.toString(), name: "EMAIL LENGTH");
                      if (numberLength == numberLength) {
                        setState(() {
                          isLoading = true;
                        });
                        if (isLoading == true) {
                          // if (loginFormKey.currentState!.validate()) {
                          dev.log("${emailController.text}", name: "Email >");
                          // await FirebaseAuth.instance.verifyPhoneNumber(
                          //   phoneNumber: "+91${emailController.text}",
                          //   verificationCompleted: (PhoneAuthCredential credential) {},
                          //   verificationFailed: (FirebaseAuthException e) {
                          //     Fluttertoast.showToast(msg: e.toString());
                          //   },
                          //   codeSent: (String verificationId, int? resendToken) {
                          //     verificationId = verificationId;
                          //     // startTimer();
                          //     setState(() {
                          //       // isotpready = true;
                          //       isLoading = false;
                          //     });
                          //     Navigator.pushReplacement(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => OtpScreen(
                          //                   verificationId: verificationId,
                          //                   phoneNumber: emailController.text.toString(),
                          //                 )));
                          //   },
                          //   codeAutoRetrievalTimeout: (String verificationId) {},
                          // );
                          // }
                          final url = Uri.https(AppSecrets.baseUrl, 'api/user/b2blogin/send-otp');
                          var headers = await _getHeaderConfig();
                          var response = await http.post(url, headers: headers, body: jsonEncode({"email": emailController.text.toString()}));
                          if (response.statusCode == 200 || response.statusCode == 201) {
                            // Fluttertoast.showToast(msg: response.body);
                            dev.log("${response.body.toString()}", name: "ON TAP >");

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EmailOtpScreen(
                                          email: emailController.text.trim(),
                                        )));
                          } else {
                            dev.log("${response.body.toString()}", name: "ON TAP >");
                            Fluttertoast.showToast(msg: response.body);
                          }
                        }
                      }
                    },
                    style: filledButtonStyle(),
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
              if (isLoading)
                Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  color: const Color(0xffF9FAFB).withOpacity(0.25),
                  child: Center(
                    child: Container(child: Lottie.asset("assets/anim/circolife_loader.json", width: 200, height: 200)),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

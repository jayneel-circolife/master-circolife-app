import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../widgets/button_styles.dart';
import '../../widgets/number_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneNumberController = TextEditingController();
  int numberLength = 0;
  bool isLoading = false;
  String verificationId = "";

  @override
  void initState() {
    super.initState();
    phoneNumberController.addListener(() {
      numberLength = phoneNumberController.text.length;
    });
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
                children: [
                  const Text("Enter your phone number"),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "OTP will be sent to this number",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  NumberTextField(
                    numberController: phoneNumberController,
                  )
                ],
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (numberLength == 10) {
                        setState(() {
                          // isloading = true;
                        });
                        if (isLoading == true) {
                          // if (loginFormKey.currentState!.validate()) {
                          // log("+91${contactController.text}", name: "Contact no. >");
                          await FirebaseAuth.instance.verifyPhoneNumber(
                            phoneNumber: "+91${phoneNumberController.text}",
                            verificationCompleted: (PhoneAuthCredential credential) {},
                            verificationFailed: (FirebaseAuthException e) {
                              Fluttertoast.showToast(msg: e.toString());
                            },
                            codeSent: (String verificationId, int? resendToken) {
                              verificationId = verificationId;
                              // startTimer();
                              setState(() {
                                // isotpready = true;
                                isLoading = false;
                              });
                            },
                            codeAutoRetrievalTimeout: (String verificationId) {},
                          );
                          // }
                        }
                      }
                    },
                    style: (numberLength == 10) ? filledButtonStyle() : hollowButtonStyle(),
                    child: Text(
                      "Login",
                      style: TextStyle(color: (numberLength == 10) ? Colors.white : const Color(0xff667085)),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:master_circolife_app/models/register_model.dart';
import 'package:master_circolife_app/presentation/home/screens/home_screen.dart';
import 'package:master_circolife_app/widgets/otp_text_field.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../../utils/secrets.dart';
import '../../widgets/button_styles.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.verificationId, required this.phoneNumber});
  final String verificationId;
  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();
  int otpLength = 0;
  bool isLoading = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  RegisterResponse? registerResponse;

  @override
  void initState() {
    super.initState();
    otpController.addListener(() {
      setState(() {
        otpLength = otpController.text.length;
      });
    });
  }

  Future isExisting() async {
    dev.log("STARTED >>>>>>>>>", name: "is existing");
    var headers = await _getHeaderConfig();
    var url = Uri.http(AppSecrets.baseUrl, '/api/user/${widget.phoneNumber.toString()}');
    dev.log(url.toString(), name: "is existing");
    var response = await http.get(
      url,
      headers: headers,
    );
    dev.log(response.statusCode.toString(), name: "response code");
    if (response.statusCode == 200 || response.statusCode == 201) {
      registerResponse = RegisterResponse.fromJson(jsonDecode(response.body));
      dev.log("${registerResponse?.userid}", name: "response---->>>");
      return true;
    } else {
      return false;
    }
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
                  OtpTextField(OTPController: otpController)
                ],
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode: otpController.text);
                        setState(() {
                          isLoading = true;
                        });
                        await auth.signInWithCredential(credential);
                        dev.log("verifying", name: "OTP");
                        // await generateToken(contactController.text.toString());
                        bool isavl = await isExisting();
                        dev.log(isavl.toString(), name: "IS EXISTING VALUE");
                        if (!isavl || registerResponse?.userid == null) {
                          Fluttertoast.showToast(msg: "NO USER");
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                        }
                      } catch (e) {
                        dev.log(e.toString(), name: "Firebase Error >");
                        if (e.toString().contains("firebase_auth/session-expired")) {
                          Fluttertoast.showToast(msg: e.toString().replaceFirst("[firebase_auth/session-expired]", "to"));
                        }
                      }
                    },
                    style: (otpLength == 10) ? filledButtonStyle() : hollowButtonStyle(),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Color(0xff667085)),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, String>> _getHeaderConfig() async {
    String? token = await appStorage?.retrieveEncryptedData('token');
    Map<String, String> headers = {};
    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    dev.log(token.toString(), name: "Token>>>>>>");
    if (token != null) {
      headers.putIfAbsent("Authorization", () => token);
    }
    dev.log(headers.toString(), name: "IS EXISTING HEADERS");
    return headers;
  }
}

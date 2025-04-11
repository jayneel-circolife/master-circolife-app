import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
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
    var url = Uri.https(AppSecrets.baseUrl, '/api/user/${widget.phoneNumber.toString()}');
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
                  Text("Enter OTP", style: TextStyle(fontSize: 24, color: Colors.grey.shade900, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Enter the OTP sent on +91 ${widget.phoneNumber}",
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
                        await generateToken(widget.phoneNumber.toString());
                        bool isavl = await isExisting();
                        dev.log(isavl.toString(), name: "IS EXISTING VALUE");
                        if (!isavl || registerResponse?.userid == null) {
                          Fluttertoast.showToast(msg: "This number is not registered with CircoLife");
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                        }
                      } catch (e) {
                        Fluttertoast.showToast(msg: e.toString());
                      }
                    },
                    style: (otpLength == 6) ? filledButtonStyle() : hollowButtonStyle(),
                    child: Text(
                      "Login",
                      style: TextStyle(color: (otpLength == 6) ? Colors.white : const Color(0xff667085)),
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

  Future<void> generateToken(String mobilenumber) async {
    var url = Uri.https(AppSecrets.baseUrl, '/api/user/authorization/jwt');
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"mobile": mobilenumber}));
    if (response.statusCode == 201 || response.statusCode == 200) {
      String jwtToken = jsonDecode(response.body.toString())["token"];
      dev.log(jwtToken.toString(), name: "JWT TOKEN>");
      await appStorage?.saveEncryptedData("token", jwtToken);
    } else {
      Fluttertoast.showToast(msg: "Something went wrong ${response.statusCode.toString()}");
    }
  }
}

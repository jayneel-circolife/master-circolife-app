import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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

              ],
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () async {

                  },
                  // style: (numberLength == 10) ? filledButtonStyle() : hollowButtonStyle(),
                  child: Text(
                    "Login",
                    style: TextStyle(color: const Color(0xff667085)),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

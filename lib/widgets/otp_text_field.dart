
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpTextField extends StatefulWidget {
  final TextEditingController? OTPController;

  const OtpTextField({@required this.OTPController, super.key});

  @override
  State<OtpTextField> createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.center,
      controller: widget.OTPController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: TextStyle(letterSpacing: 25, fontWeight: FontWeight.w800, fontSize: 17.0, color: Colors.grey.shade800, fontFamily: "Inter"),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp('[0-9]'),
        ),
      ],
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 1),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 1),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFA14996), width: 1),
          borderRadius: BorderRadius.circular(12.0),
        ),
        hintText: "OTP",
        hintStyle: const TextStyle(
          fontSize: 14.0,
          color: Color(0xFFD0D5DD),
        ),
        labelText: "",
        labelStyle: TextStyle(color: Colors.grey.shade800),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "OTP is required";
        } else if (value.length < 6) {
          return "OTP length should be at list 6";
        }
        return null;
      },
    );
  }
}

import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController? emailController;
  final bool? readonly;

  const EmailTextField({Key? key, this.emailController, this.readonly}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: emailController,
      readOnly: readonly ?? false,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textCapitalization: TextCapitalization.none,
      cursorColor: Colors.grey.shade700,
      style: TextStyle(fontSize: 16.0, color: Colors.grey.shade800),
      decoration: InputDecoration(
        hintText: "Your Email Id",
        hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 1),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Email is required";
        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
          return "Enter a valid email address";
        }
        return null;
      },
    );
  }
}

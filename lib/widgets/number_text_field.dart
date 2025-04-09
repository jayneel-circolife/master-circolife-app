import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberTextField extends StatelessWidget {
  final TextEditingController? numberController;
  final bool? readonly;
  const NumberTextField({@required this.numberController, super.key, this.readonly});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: numberController,
      keyboardType: TextInputType.phone,
      cursorColor: Colors.grey.shade700,
      textCapitalization: TextCapitalization.none,
      maxLength: 10,
      readOnly: readonly ?? false,
      maxLines: null,
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.grey.shade800,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp('[0-9]'),
        ),
      ],
      decoration: InputDecoration(
        prefix: Text(
          " +91 ",
          style: TextStyle(color: Colors.grey.shade600),
        ),
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
          borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 1),
          borderRadius: BorderRadius.circular(12.0),
        ),
        hintText: "Your mobile number",
        hintStyle: TextStyle(
          fontSize: 16.0,
          color: Colors.grey.shade500,
        ),
        labelText: "",
        labelStyle: TextStyle(color: Colors.grey.shade400),
      ),
      validator: (value) {
        if (value!.trim().isEmpty) {
          return "Mobile number is required";
        } else if (value.length < 10) {
          return "Enter valid mobile number";
        } else if (value.length > 10) {
          return "Enter valid mobile number";
        }
        return null;
      },
    );
  }
}

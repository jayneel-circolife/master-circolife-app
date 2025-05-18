import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MacAddressInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.toUpperCase().replaceAll(':', '');
    var newText = '';
    for (var i = 0; i < text.length; i++) {
      newText += text[i];
      if ((i + 1) % 2 == 0 && i < text.length - 1 && i < 10) {
        newText += ':';
      }
    }

    int newSelectionOffset = newValue.selection.end + (newText.length - newValue.text.length);
    newSelectionOffset = newSelectionOffset.clamp(0, newText.length);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionOffset),
    );
  }
}

class DeviceIdTextField extends StatelessWidget {
  final TextEditingController? deviceIdController;
  final bool? readonly;
  const DeviceIdTextField({@required this.deviceIdController, super.key, this.readonly});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: deviceIdController,
      keyboardType: TextInputType.text,
      cursorColor: Colors.grey.shade700,
      textCapitalization: TextCapitalization.characters,
      maxLength: 17,
      readOnly: readonly ?? false,
      maxLines: null,
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w800,
        color: Colors.grey.shade800,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp('[0-9a-fA-F]'),
        ),
        MacAddressInputFormatter()
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
          borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 1),
          borderRadius: BorderRadius.circular(12.0),
        ),
        hintText: "Enter Device ID",
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

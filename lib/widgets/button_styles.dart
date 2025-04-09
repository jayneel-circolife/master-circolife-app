import 'package:flutter/material.dart';

filledButtonStyle() {
  return ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 18.0, color: Color.fromARGB(255, 112, 112, 112), fontWeight: FontWeight.bold, fontFamily: "Inter"),
    minimumSize: const Size.fromHeight(56.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    backgroundColor: const Color(0xFFA14996),
  );
}

hollowButtonStyle() {
  return ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 18.0, color: Color(0xff667085), fontWeight: FontWeight.bold, fontFamily: "Inter"),
    minimumSize: const Size.fromHeight(56.0),
    side: const BorderSide(
      width: 1.0,
      color: Color(0xffD0D5DD),
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    backgroundColor: const Color(0xffF2F4F7),
  );
}
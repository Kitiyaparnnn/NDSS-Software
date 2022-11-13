import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration inputDec({required String hintText}) =>
      InputDecoration(
        fillColor: Color.fromARGB(255, 0, 0, 0),
        hintText: hintText,
        // focusColor: Colors.purple,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 1),
        ),
        contentPadding: const EdgeInsets.all(8),
      );
}

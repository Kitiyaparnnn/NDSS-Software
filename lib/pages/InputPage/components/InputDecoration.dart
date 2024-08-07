import 'package:flutter/material.dart';


class InputDecorations {
  static InputDecoration inputDec({required String hintText}) =>
      InputDecoration(
        fillColor: const Color.fromARGB(255, 0, 0, 0),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38),
        // focusColor: Colors.purple,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 1),
        ),
        contentPadding: const EdgeInsets.all(8),
      );
}

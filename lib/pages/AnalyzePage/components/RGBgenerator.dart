import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;

import '../../../myApp.dart';
import '../../../utils/Constants.dart';
import '../../../utils/PlateConfig.dart';

Plate plate = Plate();

Color abgrToColor(int argbColor) {
  int r = (argbColor >> 16) & 0xFF;
  int b = argbColor & 0xFF;
  int hex = (argbColor & 0xFF00FF00) | (b << 16) | r;
  return Color(hex);
}

Map<String, List<Color>> extractPixelsColors(Uint8List? bytes) {
  Map<String, List<Color>> colorCode = {};

  try {
    List<int> values = bytes!.buffer.asUint8List();
    imageLib.Image? image = imageLib.decodeImage(values);
    List<Color> colorOfStandard = [];
    List<Color> colorOfSample = [];
    List<int?> pixels = [];

    int? width = image?.width;
    int? height = image?.height;

    int xChunk = width! ~/ (GridConfig.noOfPixelsPerAxisX);
    int yChunk = height! ~/ (GridConfig.noOfPixelsPerAxisY);

    int left = xChunk - 1;
    int right = xChunk + 1;
    int top = yChunk + 1;
    int down = yChunk - 1;

    int midX = xChunk ~/ 2;
    int midY = yChunk ~/ 2;
    int no = 1;
    midX = midX + 1;
    midY = midY + 1;
    // xChunk = xChunk + 1;
    // yChunk = yChunk + 1;
    for (int j = 1; j < GridConfig.noOfPixelsPerAxisY + 1; j++) {
      for (int i = 1; i < GridConfig.noOfPixelsPerAxisX + 1; i++) {
        int? pixel;
        if (Plate.pnpStandard.contains(no)) {
          Color pixel1 = abgrToColor(
              (image?.getPixel(xChunk * i - midX, yChunk * j - midY))!);
          var pixel2 =
              abgrToColor((image?.getPixel(left * i - midX, down * j - midY))!);
          var pixel3 = abgrToColor(
              (image?.getPixel(right * i - midX, down * j - midY))!);
          var pixel4 =
              abgrToColor((image?.getPixel(left * i - midX, top * j - midY))!);
          var pixel5 =
              abgrToColor((image?.getPixel(right * i - midX, top * j - midY))!);

          colorOfStandard.add(pixel1);
          colorOfStandard.add(pixel2);
          colorOfStandard.add(pixel3);
          colorOfStandard.add(pixel4);
          colorOfStandard.add(pixel5);
        } else if (Plate.pnpSample!.contains(no)) {
          pixel = image?.getPixel(xChunk * i - midX, yChunk * j - midY);
          pixels.add(pixel);
          Color c = abgrToColor(pixel!);
          colorOfSample.add(c);
        }
        no++;
      }
    }
    // print(colorOfStandard.length);
    colorCode[PreferenceKey.standard] = colorOfStandard;
    colorCode[PreferenceKey.sample] = colorOfSample;

    // logger.d(colorOfStandard);
  } catch (e) {
    logger.e('Fail: can not get RGB code from image');
  }

  return colorCode;
}

List<int> getColorValue(List<Color> c, String color) {
  List<int> value = [];

  try {
    if (color == 'red') {
      c.forEach((c) => value.add(c.red));
    }
    if (color == 'green') {
      c.forEach((c) => value.add(c.green));
    }
    if (color == 'blue') {
      c.forEach((c) => value.add(c.blue));
    }
  } catch (e) {
    logger.e('Fail: can not convert hexcode to rgbcode');
  }
  return value;
}

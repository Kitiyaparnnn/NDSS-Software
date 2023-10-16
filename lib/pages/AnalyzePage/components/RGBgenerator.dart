import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;

import '../../../myApp.dart';
import '../../../utils/Constants.dart';
import '../../../utils/PlateConfig.dart';

Plate plate = Plate();

// Color abgrToColor(int argbColor) {
//   int r = (argbColor >> 16) & 0xFF;
//   int b = argbColor & 0xFF;
//   int hex = (argbColor & 0xFF00FF00) | (b << 16) | r;
//   return Color(hex);
// }

Map<String, List<List<num>>> extractPixelsColors(Uint8List? bytes) {
  Map<String, List<List<num>>> colorCode = {};

  try {
    List<int> values = bytes!.buffer.asUint8List();

    Uint8List bytes2 = Uint8List.fromList(values);
    imageLib.Image? image = imageLib.decodeImage(bytes2);
    print('result: ${image}');

    List<List<num>> colorOfStandard = [];
    List<List<num>> colorOfSample = [];
    List<List<num>> pixels = [];

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
    midX = midX + 5;
    midY = midY + 5;
    // // xChunk = xChunk + 1;
    // // yChunk = yChunk + 1;
    for (int j = 1; j < GridConfig.noOfPixelsPerAxisY + 1; j++) {
      for (int i = 1; i < GridConfig.noOfPixelsPerAxisX + 1; i++) {
        if (Plate.pnpStandard.contains(no)) {
          var pixel1 = image!.getPixel(xChunk * i - midX, yChunk * j - midY).toList();
          print('example: ${pixel1}');
          var pixel2 = image.getPixel(left * i - midX, down * j - midY).toList();
          var pixel3 = image.getPixel(right * i - midX, down * j - midY).toList();
          var pixel4 = image.getPixel(left * i - midX, top * j - midY).toList();
          var pixel5 = image.getPixel(right * i - midX, top * j - midY).toList();
          // var pixel1 = abgrToColor(
          //     (image?.getPixelSafe(xChunk * i - midX, yChunk * j - midY)));
          // var pixel2 = abgrToColor(
          //     (image?.getPixelSafe(left * i - midX, down * j - midY))! as int);
          // var pixel3 = abgrToColor(
          //     (image?.getPixelSafe(right * i - midX, down * j - midY))! as int);
          // var pixel4 = abgrToColor(
          //     (image?.getPixelSafe(left * i - midX, top * j - midY))! as int);
          // var pixel5 = abgrToColor(
          //     (image?.getPixelSafe(right * i - midX, top * j - midY))! as int);

          colorOfStandard.add(pixel1);
          colorOfStandard.add(pixel2);
          colorOfStandard.add(pixel3);
          colorOfStandard.add(pixel4);
          colorOfStandard.add(pixel5);
        }
        // int? pixel;
        else if (Plate.pnpSample!.contains(no)) {
          var pixel = image!.getPixel(xChunk * i - midX, yChunk * j - midY).toList();
          pixels.add(pixel);
          // Color c = abgrToColor(pixel!);
          colorOfSample.add(pixel);
        }
        no++;
      }
    }
    print('${colorOfStandard.length}');
    colorCode[PreferenceKey.standard] = colorOfStandard;
    colorCode[PreferenceKey.sample] = colorOfSample;

    // logger.d(colorOfStandard);
  } catch (e) {
    logger.e('Fail: can not get RGB code from image');
  }

  return colorCode;
}

List<int> getColorValue(List<List<num>> c, String color) {
  List<int> value = [];

  try {
    if (color == 'red') {
      for (var c in c) {
        value.add(c[0].toInt());
      }
    }
    if (color == 'green') {
      c.forEach((c) => value.add(c[1].toInt()));
    }
    if (color == 'blue') {
      c.forEach((c) => value.add(c[2].toInt()));
    }
  } catch (e) {
    logger.e('Fail: can not convert hexcode to rgbcode');
  }
  return value;
}

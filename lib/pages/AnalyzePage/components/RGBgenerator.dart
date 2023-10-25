import 'dart:typed_data';
import 'package:image/image.dart' as imageLib;

import '../../../myApp.dart';
import '../../../utils/Constants.dart';
import '../../../utils/PlateConfig.dart';

Plate plate = Plate();

Map<String, List<List<num>>> extractPixelsColors(Uint8List? bytes) {
  Map<String, List<List<num>>> colorCode = {};

  try {
    List<int> values = bytes!.buffer.asUint8List();

    Uint8List bytes2 = Uint8List.fromList(values);
    imageLib.Image? image = imageLib.decodeImage(bytes2);
    print('result: ${image}');

    List<List<num>> colorOfStandard = [];
    List<List<num>> colorOfSample = [];


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

    for (int j = 1; j < GridConfig.noOfPixelsPerAxisY + 1; j++) {
      for (int i = 1; i < GridConfig.noOfPixelsPerAxisX + 1; i++) {
        var pixel1 =
            image!.getPixel(xChunk * i - midX, yChunk * j - midY).toList();

        var pixel2 = image.getPixel(left * i - midX, down * j - midY).toList();
        var pixel3 = image.getPixel(right * i - midX, down * j - midY).toList();
        var pixel4 = image.getPixel(left * i - midX, top * j - midY).toList();
        var pixel5 = image.getPixel(right * i - midX, top * j - midY).toList();
        if (Plate.pnpStandard.contains(no)) {

          colorOfStandard.add(pixel1);
          colorOfStandard.add(pixel2);
          colorOfStandard.add(pixel3);
          colorOfStandard.add(pixel4);
          colorOfStandard.add(pixel5);
        }
        // int? pixel;
        else if (Plate.pnpSample!.contains(no)) {
          colorOfSample.add(pixel1);
          colorOfSample.add(pixel2);
          colorOfSample.add(pixel3);
          colorOfSample.add(pixel4);
          colorOfSample.add(pixel5);
        }
        no++;
      }
    }

    colorCode[PreferenceKey.standard] = colorOfStandard;
    colorCode[PreferenceKey.sample] = colorOfSample;


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

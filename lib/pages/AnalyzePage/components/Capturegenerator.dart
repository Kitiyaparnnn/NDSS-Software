import 'dart:convert';
import 'dart:math';
import 'package:image/image.dart' as imageLib;


import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../utils/Constants.dart';


Future cropSquare(File imageFile, bool flip) async {
  List<File> crop = [];
  var bytes = await imageFile.readAsBytes();
  imageLib.Image? src = imageLib.decodeImage(bytes);

  var cropSizeX = src!.width ~/ GridConfig.noOfPixelsPerAxisX ;
  var cropSizeY = src.height ~/ GridConfig.noOfPixelsPerAxisY  ;

  for(int i = 0;i<GridConfig.noOfPixelsPerAxisY;i++){
    for(int j = 0;j<GridConfig.noOfPixelsPerAxisX ;j++){
      imageLib.Image destImage =
      imageLib.copyCrop(src, j*cropSizeX, i*cropSizeY, cropSizeX, cropSizeY);

      if (flip) {
        destImage = imageLib.flipVertical(destImage);
      }

      var jpg = imageLib.encodeJpg(destImage);

      Directory imagePath = await getApplicationDocumentsDirectory();
      String path = imagePath.path;

      File file = File(join(imagePath.path,
          '${DateTime.now().toUtc().toIso8601String()}.png'));
      file.writeAsBytesSync(jpg);
      crop.add(file);
    }

  }

  return crop;

}

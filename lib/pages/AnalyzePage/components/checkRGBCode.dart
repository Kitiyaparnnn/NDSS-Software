import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../utils/Constants.dart';

Widget _colorCheck(File? imageFile, Uint8List? imageBytes, List<Color> colors) {
  return Container(
    child: ListView(
      children: [
        SizedBox(
          height: 20,
        ),
        SizedBox(
          child: imageBytes != null && imageBytes.length > 0
              ? Image.file(
                  imageFile!,
                  fit: BoxFit.fill,
                )
              : Center(child: CircularProgressIndicator()),
          // height: 250,
        ),
        SizedBox(
          height: 10,
        ),
        _getGrids(colors),
      ],
    ),
  );
}

Widget _getGrids(List<Color> colors) {
  return SizedBox(
    // height: 200,
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: colors.isEmpty
              ? Container(
                  child: CircularProgressIndicator(),
                  alignment: Alignment.center,
                  height: 200,
                )
              : Column(
                  children: [
                    Text(
                      'Extracted Pixels',
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: GridConfig.noOfPixelsPerAxisX),
                        itemCount: colors.length,
                        itemBuilder: (BuildContext ctx, index) {
                          return Container(
                            alignment: Alignment.center,
                            child: Container(
                              color: colors[index],
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                color: Colors.grey),
                          );
                        }),
                  ],
                ),
        )
      ],
    ),
  );
}

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../utils/Constants.dart';

Widget _colorCheck(File? imageFile, Uint8List? imageBytes, List<Color> colors) {
  return Container(
    child: ListView(
      children: [
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          child: imageBytes != null && imageBytes.isNotEmpty
              ? Image.file(
                  imageFile!,
                  fit: BoxFit.fill,
                )
              : const Center(child: CircularProgressIndicator()),
          // height: 250,
        ),
        const SizedBox(
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
                  alignment: Alignment.center,
                  height: 200,
                  child: const CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    const Text(
                      'Extracted Pixels',
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: GridConfig.noOfPixelsPerAxisX),
                        itemCount: colors.length,
                        itemBuilder: (BuildContext ctx, index) {
                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                color: Colors.grey),
                            child: Container(
                              color: colors[index],
                            ),
                          );
                        }),
                  ],
                ),
        )
      ],
    ),
  );
}

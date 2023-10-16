import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:ndss_mobile/utils/ColorConfig.dart';
import 'package:ndss_mobile/utils/TextConfig.dart';

class LoadCsvDataScreen extends StatelessWidget {
  final String path;
  final String title;

  LoadCsvDataScreen({required this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_rounded,
            color: ColorCode.iconsAppBar,
          ),
        ),
        title: Text("$title .csv", style: StyleText.appBar),
      ),
      body: FutureBuilder(
        future: loadingCsvData(path),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          // print(snapshot.data.toString());
          return snapshot.hasData
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: snapshot.data!
                          .map(
                            (data) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    data[0].toString(),
                                  ),
                                  Text(
                                    data[1].toString(),
                                  ),
                                  Text(
                                    data[2].toString(),
                                  ),
                                  Text(
                                    data[3].toString(),
                                  ),
                                  Text(
                                    data[4].toString(),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }

  Future<List<List<dynamic>>> loadingCsvData(String path) async {
    final csvFile = new File(path).openRead();
    return await csvFile
        .transform(utf8.decoder)
        .transform(
          CsvToListConverter(),
        )
        .toList();
  }
}

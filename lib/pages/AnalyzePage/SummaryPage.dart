import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:ndss_mobile/pages/AnalyzePage/components/ConvertUgToUgM3.dart';
import 'package:scidart/numdart.dart';
import 'package:image/image.dart' as imageLib;
import '../../models/ReportInfo.dart';
import '../../myApp.dart';
import '../../utils/ColorConfig.dart';
import '../../utils/Constants.dart';
import '../../utils/TextConfig.dart';
import 'ReportPage.dart';
import 'components/Graphgenerator.dart';
import 'components/PDFprintgenerate.dart';
import 'components/RGBgenerator.dart';
import 'components/reportHeader.dart';

class SummaryPage extends StatefulWidget {
  final File? imageFile;
  ReportInfo report;

  SummaryPage({this.imageFile, required this.report});
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  bool waiting = true;
  late final FileImage flutter;
  Uint8List? imageBytes;
  Map<String, List<List<num>>>? colors;
  List<int> red = [];
  List<int> green = [];
  List<int> blue = [];
  List<double> con = [];
  late PolyFit equation;
  double result = 0;

  Offset localPosition = const Offset(0, 0);
  Color color = const Color(0x00000000);

  @override
  void initState() {
    FlutterNativeSplash.remove();
    delay();
    super.initState();
  }

  delay() async {
    await Future.delayed(const Duration(seconds: 10));
    await extractColors();
    await conStandard();
    flutter = FileImage(widget.imageFile!);
    waiting = false;
    setState(() {});
  }

  Future<void> extractColors() async {
    imageBytes = await _readFileByte(widget.imageFile);
    // print(imageBytes);
    colors = await compute(extractPixelsColors, imageBytes);
    colors!.forEach((key, value) {
      red.addAll(getColorValue(colors![key]!, 'red'));
      green.addAll(getColorValue(colors![key]!, 'green'));
      blue.addAll(getColorValue(colors![key]!, 'blue'));
    });
    // print(red.length);
    widget.report.red = red;
    widget.report.green = green;
    widget.report.blue = blue;
  }

  Future<Uint8List> _readFileByte(File? filePath) async {
    File audioFile = filePath!;
    Uint8List bytes = (await rootBundle.load('lib/assets/images/NO2.jpg'))
        .buffer
        .asUint8List();
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      print('reading of bytes is completed');
    }).catchError((onError) {
      print('Exception Error while reading audio from path:' +
          onError.toString());
    });
    return bytes;
  }

  calCon() {
    List<double> con = [];
    for (double i in widget.report.con[widget.report.evaluate]!) {
      for (int j = 0; j < 5; j++) {
        con.add(i);
      }
    }
    return con;
  }

  conStandard() async {
    // print(con);
    // con = widget.report.con[widget.report.evaluate]!;

    List<double> standard = widget.report.calStandard();
    equation = calRsquare(standard, calCon());
    logger.d(equation);
  }

  double ugToug3(double x, ReportInfo report) {
    const L = 7;
    const D = 0.154;
    const A = 0.785;

    double r = (x * 2 * L) / (D * A * report.time) * pow(10, 6);

    logger.d("convert finish!");
    return r;
  }

  double calConcentrate(PolyFit equation, Color colorCode) {
    double sample = 0;
    try {
      if (widget.report.evaluate == PreferenceKey.nitrogenDi) {
        sample = colorCode.green.toDouble();
      }

      result = equation.predict(sample);
      // result = 1;
    } catch (e) {
      logger.e('Fail: cal concentrate');
      result = 0;
    }
    return ugToug3(result, widget.report);
  }

  @override
  Widget build(BuildContext context) {
    var report = widget.report;
    result = ugToug3(result, report);
    // logger.d(report.evaluate);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            color: ColorCode.iconsAppBar,
            onPressed: () {
              printScreen(_printKey);
            },
            icon: Icon(
              Icons.print_rounded,
            ),
          )
        ],
        title: Text(PreferenceKey.report, style: StyleText.appBar),
      ),
      body: SizedBox.expand(
        child: RepaintBoundary(
          key: _printKey,
          child: Column(
            children: [
              reportHeader(report.name, report.evaluate),
              // SizedBox(height: 10),
              Expanded(
                  flex: 4,
                  child: waiting
                      ? Center(
                          child: Container(
                              child: CircularProgressIndicator(
                          semanticsLabel: "loading...",
                        )))
                      : Padding(
                          padding: const EdgeInsets.all(0),
                          child: Center(
                              child: Container(
                            color: Colors.white,
                            child: Listener(
                              onPointerDown: (PointerDownEvent details) {
                                setState(() {
                                  localPosition = details.localPosition;
                                  print("position: $localPosition");
                                });
                              },
                              child: ImagePixels(
                                  imageProvider: flutter,
                                  builder:
                                      (BuildContext context, ImgDetails img) {
                                    int w =
                                        img.width != null ? img.width! : 500;
                                    int h =
                                        img.height != null ? img.height! : 500;
                                    double scaleW =
                                        MediaQuery.of(context).size.width / w;

                                    color = img.pixelColorAt!(
                                        (localPosition.dx / scaleW).toInt(),
                                        (localPosition.dy).toInt());

                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      setState(() {
                                        if (color != this.color) {
                                          this.color = color;
                                        }
                                      });
                                    });
                                    calConcentrate(equation, color);
                                    return SizedBox(
                                      // height: h.toDouble(),
                                      width: MediaQuery.of(context).size.width,
                                      child: Stack(children: [
                                        Image.file(
                                          flutter.file,
                                          fit: BoxFit.fill,
                                        ),
                                        Positioned(
                                            left: localPosition.dx - 10,
                                            top: localPosition.dy - 22,
                                            // height: h.toDouble(),
                                            child:
                                                Icon(Icons.push_pin_rounded)),
                                      ]),
                                    );
                                  }),
                            ),
                          )))),

              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Colors: ", style: StyleText.normalText),
                        SizedBox(
                          width: 10,
                        ),
                        Container(width: 100, height: 55, color: color),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Coordinate (x,y) : (${localPosition.dx.toStringAsFixed(2)},${localPosition.dy.toStringAsFixed(2)})",
                                style: StyleText.normalText),
                            Text("R: ${color.red}",
                                style: StyleText.normalText),
                            Text("G: ${color.green}",
                                style: StyleText.normalText),
                            Text("B: ${color.blue}",
                                style: StyleText.normalText),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                                "Concentration of Samples: ${(result * 2).toStringAsFixed(2)} ug/m3",
                                style: StyleText.headerText)
                          ]),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

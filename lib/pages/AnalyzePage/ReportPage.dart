import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:async';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:scidart/numdart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as exLib;

import '../../load_data_csv.dart';
import '../../myApp.dart';
import '../../utils/ColorConfig.dart';
import '../../utils/Constants.dart';
import '../../utils/PlateConfig.dart';
import '../../utils/TextConfig.dart';
import 'components/Capturegenerator.dart';
import 'components/ConvertUgToUgM3.dart';
import 'components/Graphgenerator.dart';
import 'components/PDFprintgenerate.dart';
import 'components/RGBgenerator.dart';
import '../../models/ReportInfo.dart';
import 'components/reportHeader.dart';

class ReportPage extends StatefulWidget {
  final File? imageFile;
  ReportInfo report;

  ReportPage({this.imageFile, required this.report});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  bool waiting = true;
  Map<String, List<Color>>? colors;
  List<int> red = [];
  List<int> green = [];
  List<int> blue = [];
  late PolyFit equation;
  List<double> result = [];
  Uint8List? imageBytes;
  List<double> con = [];

  List<File> file = [];

  Plate plate = Plate();

  late var minimum;
  late var maximum;

  @override
  void initState() {
    delay();
    logger.d({
      'report name: ${widget.report.name}',
      'report evaluate: ${widget.report.evaluate}',
      'report time: ${widget.report.time}'
    });
    super.initState();
  }

  delay() async {
    await Future.delayed(const Duration(seconds: 10));
    await extractColors();
    await conStandard();
    await cropImage();
    minimum = widget.report.calStandard().reduce(min);
    maximum = widget.report.calStandard().reduce(max);
    waiting = false;
    setState(() {});
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

    List<double> standard = widget.report.calStandard();
    // logger.d({'standard : ${standard.length},con : ${calCon().length}'});
    equation = calRsquare(standard, calCon());
    logger.d(equation);
  }

  selectImage(List<File> file) {
    List<File> selected = [];
    for (int i = 1; i < file.length + 1; i++) {
      if (Plate.pnpStandard.contains(i) || Plate.pnpSample!.contains(i)) {
        selected.add(file[i - 1]);
        // print(i);
      }
    }
    print('#selectedCrop: ${selected.length}');
    return selected;
  }

  cropImage() async {
    file = await cropSquare(widget.imageFile!, false);
    var length = file.length;
    print('#cropPerImage: $length');
    file = selectImage(file);
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

  List<ChartData> calScatter(String type) {
    result = calConcentrate(equation, widget.report.calSample());
    print('#calScatter complete');
    return getData(
        type == PreferenceKey.standard ? calCon() : result,
        type == PreferenceKey.standard
            ? widget.report.calStandard()
            : widget.report.calSample());
  }

  List<ChartData> calLine() {
    // var zero = -equation.coefficient(0) / equation.coefficient(1);
    // print(zero);
    List<double> sample = [for (double i = minimum; i <= maximum; i++) i];
    result = calConcentrate(equation, sample);

    print('#calLine complete');
    return getData(result, sample);
  }

  Widget _showChart() {
    return Center(
      child: waiting
          ? CircularProgressIndicator()
          : Container(
              height: 400,
              //Initialize chart
              child: SfCartesianChart(
                tooltipBehavior: TooltipBehavior(
                    enable: true,
                    tooltipPosition: TooltipPosition.pointer,
                    borderColor: Colors.red,
                    borderWidth: 5,
                    color: Colors.lightBlue),
                title: ChartTitle(
                  text: 'Standard Linear Regression',
                  textStyle: TextStyle(fontSize: 12),
                ),
                primaryXAxis:
                    NumericAxis(minimum: 0, interval: 0.1, maximum: 0.7),
                legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap),
                primaryYAxis: NumericAxis(
                    minimum: minimum, maximum: maximum, interval: 10),
                series: <CartesianSeries>[
                  ScatterSeries<ChartData, double>(
                      legendItemText: PreferenceKey.standard,
                      enableTooltip: true,
                      dataSource: calScatter(PreferenceKey.standard),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y),
                  LineSeries<ChartData, double>(
                      legendItemText: 'y = ' +
                          equation.coefficient(1).toStringAsFixed(3) +
                          'x' +
                          '+' +
                          equation.coefficient(0).toStringAsFixed(3) +
                          ' (R^2 =' +
                          equation.R2().toStringAsFixed(3) +
                          ')',
                      enableTooltip: true,
                      dataSource: calLine(),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y),
                  ScatterSeries<ChartData, double>(
                      legendItemText: PreferenceKey.sample,
                      enableTooltip: true,
                      dataSource: calScatter(PreferenceKey.sample),
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y),
                ],
              ),
            ),
    );
  }

  _showImage() {
    return result.isEmpty
        ? CircularProgressIndicator()
        : Stack(children: [
            Container(
              height: 300,
              child: Image.file(widget.imageFile!,
                  semanticLabel: "18-well plates", fit: BoxFit.fill),
            ),
            for (int i = 1; i < 6; i++)
              Positioned(
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: EdgeInsets.all(8.0),
                    message:
                        con.isEmpty ? "xx.xx" : con[i - 1].toStringAsFixed(2),
                    child: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.green),
                  ),
                  top: 18.75 * 3,
                  left: (MediaQuery.of(context).size.width * i / 6.0) + 3),
            for (int i = 1; i < 6; i++)
              Positioned(
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: EdgeInsets.all(8.0),
                    message:
                        con.isEmpty ? "xx.xx" : con[i - 1].toStringAsFixed(2),
                    child: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.green),
                  ),
                  top: 18.75 * 5,
                  left: (MediaQuery.of(context).size.width * i / 6.0) + 3),
            for (int i = 1; i < 11; i++)
              Positioned(
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: EdgeInsets.all(8.0),
                    message: result.isEmpty
                        ? "xx.xx"
                        : (result[i - 1] * 2).toStringAsFixed(2),
                    child: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.red),
                  ),
                  top: 18.75 * 7,
                  left: (MediaQuery.of(context).size.width * i / 6.0) + 3),
            for (int i = 1; i < 11; i++)
              Positioned(
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: EdgeInsets.all(8.0),
                    message: result.isEmpty
                        ? "xx.xx"
                        : (result[i + 10 - 1] * 2).toStringAsFixed(2),
                    child: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.red),
                  ),
                  top: 18.75 * 9,
                  left: (MediaQuery.of(context).size.width * i / 6.0) + 3),
            for (int i = 1; i < 11; i++)
              Positioned(
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: EdgeInsets.all(8.0),
                    message: result.isEmpty
                        ? "xx.xx"
                        : (result[i + 20 - 1] * 2).toStringAsFixed(2),
                    child: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.red),
                  ),
                  top: 18.75 * 11,
                  left: (MediaQuery.of(context).size.width * i / 6.0) + 3),
            for (int i = 1; i < 11; i++)
              Positioned(
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    padding: EdgeInsets.all(8.0),
                    message: result.isEmpty
                        ? "xx.xx"
                        : (result[i + 30 - 1] * 2).toStringAsFixed(2),
                    child: Icon(Icons.check_circle_outline_outlined,
                        color: Colors.red),
                  ),
                  top: 18.75 * 13,
                  left: (MediaQuery.of(context).size.width * i / 6.0) + 3)
          ]);
  }

  List<List<String>> smp = [];

  Widget _showResult() {
    con = calCon();

    int i = 0;
    int j = 0;
    int n = -1;

    result = ugToug3(result, widget.report);
    // logger.i(result);
    return file.length == 0
        ? SizedBox(
            height: 10,
          )
        : GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
            ),
            itemCount: file.length,
            itemBuilder: (BuildContext ctx, index) {
              String title;
              String concentrate;
              String rgbCode;
              if (Plate.pnpStandard.contains(index + 1)) {
                title = 'Std';
                concentrate = con[i * 5].toStringAsFixed(2);
                rgbCode = widget.report.standard[i * 5].toStringAsFixed(0);
                i++;
              } else {
                var number = index % 6;
                if (number == 0) n++;
                title = plate.label[n] + plate.no[number].toString();
                concentrate = (result[j]).toStringAsFixed(2);
                rgbCode = widget.report.sample[j].toStringAsFixed(0);
                smp.add(["$title", "SMP", "$concentrate"]);
                j++;
              }
              return Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Text(title + '=' + '$concentrate',
                        style: StyleText.resultText),
                    Image.file(
                      file[index],
                      fit: BoxFit.contain,
                      height: 32,
                      width: 50,
                    ),
                    Text(
                      rgbCode,
                      style: StyleText.resultText,
                    )
                  ],
                ),
              );
            },
          );
  }

  _showExportButton() {
    return waiting
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      textStyle: StyleText.buttonText,
                      backgroundColor: ColorCode.appBarColor,
                    ),
                    onPressed: () {
                      generateCsv();
                    },
                    icon: Icon(
                      Icons.file_upload,
                      color: Colors.white,
                    ),
                    label: Text('CSV', style: StyleText.buttonText)),
              ),
            ],
          );
  }

  Future generateCsv() async {
    List<List<String>> std = [];
    int j = 0;
    while (j < widget.report.standard.length) {
      List label = ['A', 'B', 'C'];
      int x = j ~/ 5;
      for (int i = 0; i < 5; i++) {
        std.add([
          "${x < 4 ? (x < 2 ? label[0] : label[1]) : label[2]}${Plate.pnpStandard[x]}",
          "STD",
          "${con[x * 5].toStringAsFixed(2)}"
        ]);
        j++;
      }
    }
    print("row of std: ${std.length}");
    print("row of smp: ${smp.length}");

    List<List<String>> data = [
          ["well_index", "STD/SMP", "nitrogen dioxide\n     (ug/m3)"]
        ] +
        std.toList() +
        smp.toList();
    String csvData = ListToCsvConverter().convert(data);
    final String directory = (await getExternalStorageDirectory())!.path;
    final path = "$directory/m-css-${widget.report.name}-${DateTime.now()}.csv";
    final File file = File(path);
    await file.writeAsString(csvData);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return LoadCsvDataScreen(title: widget.report.name, path: path);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var report = widget.report;
    return Scaffold(
        key: UniqueKey(),
        appBar: AppBar(
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
        body: SingleChildScrollView(
          child: RepaintBoundary(
            key: _printKey,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  reportHeader(report.name, report.evaluate),

                  _showChart(),
                  // SizedBox(height: 10),
                  // _showImage(),
                  _showExportButton(),
                  Container(child: _showResult()),
                ],
              ),
            ),
          ),
        ));
  }
}

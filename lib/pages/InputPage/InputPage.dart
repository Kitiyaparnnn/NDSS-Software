import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/Constants.dart';
import '../../utils/PlateConfig.dart';
import '../../utils/TextConfig.dart';
import '../AnalyzePage/SummaryPage.dart';
import 'components/InputDecoration.dart';
import '../AnalyzePage/ReportPage.dart';

import '../../models/ReportInfo.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController reportName = TextEditingController();
  String dropdownValue = PreferenceKey.inputForm;
  File? imageFile;
  File? _image;
  ReportInfo report = ReportInfo('', '', [], [], []);

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
    reportName.clear();
    // report.evaluate = dropdownValue;
  }

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Please choose an option",
              style: StyleText.headerText,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _getFromCamera();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _getFromGallery();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxHeight: 1080, maxWidth: 1080);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromCamera() async {
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 1080,
        maxWidth: 1080,
        // aspectRatioPresets: [
        //   CropAspectRatioPreset.original,
        // ],
        androidUiSettings: const AndroidUiSettings(
          cropGridRowCount: 2,
          cropGridColumnCount: 5,
        ));

    if (croppedFile != null) {
      _saveImage();
      setState(() {
        imageFile = croppedFile;
      });
    }
  }

  Future _saveImage() async {
    Directory imagePath = await getApplicationDocumentsDirectory();
    String path = imagePath.path;
    File newImage = await imageFile!.copy('$path/image1.png');
    setState(() {
      _image = newImage;
    });
    print('imagePath: $_image');
  }

  Widget _checkBox(String evaluate, int index) {
    Widget? isIcon;
    if (evaluate == 'Nitrogen Dioxide') {
      //standard
      if (Plate.pnpStandard.contains(index)) {
        isIcon = Icon(
          Icons.check_circle_outline_outlined,
          color: Colors.green,
        );
      }
      //sample
      if (Plate.pnpSample!.contains(index)) {
        isIcon = Icon(
          Icons.check_circle_outline_outlined,
          color: Colors.red,
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: isIcon,
    );
  }

  Widget _analyzTap() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        textStyle: StyleText.normalText,
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: () {
        imageFile == null || report.evaluate == PreferenceKey.inputForm
            ? BotToast.showText(text: PreferenceKey.noti)
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => SummaryPage(
                          imageFile: _image,
                          report: report,
                        )));
      },
      child: Text(PreferenceKey.analyzTap, style: StyleText.buttonText),
    );
  }

  Widget _analyzAll() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        textStyle: StyleText.normalText,
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: () {
        imageFile == null || report.evaluate == PreferenceKey.inputForm
            ? BotToast.showText(text: PreferenceKey.noti)
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ReportPage(
                    imageFile: _image,
                    report: report,
                  ),
                ),
              );
      },
      child: Text(PreferenceKey.analyzAll, style: StyleText.buttonText),
    );
  }

  Widget _inputReportName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(PreferenceKey.nameTitle, style: StyleText.headerText),
        SizedBox(
          height: 5,
        ),
        TextFormField(
          controller: reportName,
          onChanged: (context) => setState(() {
            report.name = context;
          }),
          decoration: InputDecorations.inputDec(hintText: 'example'),
          style: StyleText.normalText,
        ),
        SizedBox(
          height: 10,
        ),
        Text(PreferenceKey.evaluateTitle, style: StyleText.headerText),
        SizedBox(
          height: 5,
        ),
        InputDecorator(
          decoration: InputDecorations.inputDec(hintText: ''),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              hint: Text('สาร'),
              value: dropdownValue,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 4,
              style: StyleText.normalText,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  report.name = reportName.text.toString();
                  report.evaluate = dropdownValue;
                });
              },
              items: PreferenceKey.evaluate
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: StyleText.normalText),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // print("use build State");

    return Scaffold(
      appBar: AppBar(
        title: Text("M-NDSS v.1", style: StyleText.appBar),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        _inputReportName(),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    PreferenceKey.imageTitle,
                                    style: StyleText.headerText,
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      textStyle: StyleText.normalText,
                                    ),
                                    onPressed: _showImageDialog,
                                    child: Text(
                                      imageFile == null
                                          ? "อัพโหลดรูปภาพ"
                                          : "เปลี่ยนรูปภาพ",
                                      style: StyleText.buttonText,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width,
                                  maxHeight: 252,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                ),
                                child: Stack(
                                  children: [
                                    imageFile != null
                                        ? Image.file(imageFile!,
                                            width: double.infinity,
                                            height: double.infinity,
                                            semanticLabel: "18-well plates",
                                            fit: BoxFit.fill)
                                        : Center(
                                            child: Text(
                                              "ไม่มีรูปภาพ",
                                              style: StyleText.normalText,
                                              textAlign: TextAlign.center,
                                            ),
                                            widthFactor: double.infinity,
                                            heightFactor: double.infinity,
                                          ),
                                    GridView.count(
                                      shrinkWrap: true,
                                      // physics: NeverScrollableScrollPhysics(),
                                      crossAxisCount: 6,
                                      children: List.generate(
                                          18,
                                          (index) => _checkBox(
                                              dropdownValue, index + 1)),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                        SizedBox(
                          height: 10,
                        ),
                        _analyzTap(),
                        SizedBox(
                          height: 10,
                        ),
                        _analyzAll()
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

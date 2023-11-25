import 'dart:core';
import '../myApp.dart';
import '../utils/Constants.dart';
import '../utils/PlateConfig.dart';

class ReportInfo {
  String name;
  String evaluate;
  int time;

  List<int> red;
  List<int> green;
  List<int> blue;
  ReportInfo(
      this.name, this.evaluate, this.time, this.red, this.green, this.blue);

  List<double> standard = [];
  List<double> sample = [];
  Map<String, List<double>> con = {
    PreferenceKey.nitrogenDi: [0, 0.46, 0.18, 0.55, 0.37, 0.69]
  };

  Plate plate = Plate();

  List<double> calStandard() {
    // print(red.length);
    // print(Plate.pnpStandard);
    this.standard = [];
    // print(this.evaluate);
    try {
      if (this.evaluate == PreferenceKey.nitrogenDi) {
        for (int i = 1; i < 31; i++) {
          standard.add(green[i - 1].toDouble());
        }
      }
    } catch (e) {
      logger.e('Fail: calculate standard value');
    }
    // print(standard);
    return standard;
  }

  List<double> calSample() {
    // print(Plate.php);
    this.sample = [];
    try {
      if (this.evaluate == PreferenceKey.nitrogenDi) {
        for (int i = 31; i <= 90; i++) {
          sample.add(green[i - 1].toDouble());
        }
      }
    } catch (e) {
      logger.e('Failed: calculate sample value');
    }
    // print(sample);
    return sample;
  }
}

import 'package:scidart/numdart.dart';
import '../../../myApp.dart';

class ChartData {
  ChartData(this.x, this.y);
  final double x;
  final double y;
}

PolyFit calRsquare(List<double> x, List<double> y) {
  // print('x: $x');
  // print('y: $y');

  // print(x.length);
  // print(y.length);
  var equation = PolyFit(Array(x), Array(y), 1);
  // print(equation);

  return equation;
}

List<double> calConcentrate(PolyFit equation, List<double> sample) {
  List<double> result = [];
  try {
    for (var code in sample) {
      result.add(equation.predict(code));
      // logger.d('$code : ${result.last}');
    }

    var length = result.length;
    print('#concentrate: $length');
  } catch (e) {
    logger.e('Fail: cal concentrate');
  }
  return result;
}

List<ChartData> getData(List<double> result, List<double> rgbCode) {
  // Future.delayed(Duration(seconds: 10));
  List<ChartData> data = [];
  logger.d({'samples : ${rgbCode.length}},con : ${result.length}'});
  try {
    for (int i = 0; i < result.length; i++) {
      data.add(ChartData(result[i], rgbCode[i]));
    }
  } catch (e) {
    logger.e('Fail: generate ChartData');
  }
  return data;
}

  import 'dart:math';

import 'package:ndss_mobile/models/ReportInfo.dart';
import '../../../myApp.dart';

List<double> ugToug3(List<double> x, ReportInfo report) {
    const L = 7;
    const D = 0.154;
    const A = 0.785;
    List<double> r = [];
    for (var i in x) {
      r.add((i * 2 * L) / (D * A *report.time) * pow(10, 6));
    }
    logger.d("convert finish!");
    return r;
  }
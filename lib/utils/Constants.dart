class GridConfig {
  static int noOfPixelsPerAxisX = 6;
  static int noOfPixelsPerAxisY = 3;
}

class PreferenceKey {
  static const List<String> evaluate = ['Nitrogen Dioxide'];
  static const String standard = 'Standard';
  static const String sample = 'Sample';
  // static const String phosphate = 'Phosphate';
  // static const String nitrate = 'Nitrate';
  // static const String potassium = 'Potassium';
  static const String nitrogenDi = 'Nitrogen Dioxide';

  static const String h_well_index = 'well_index';
  static const String h_std_smp = 'STD/SMP';
  static const String h_color_R = 'color_R';
  static const String h_color_G = 'color_G';
  static const String h_color_B = 'color_B';
  static const String h_HSV = 'HSV';
  static const String h_saturation = 'Saturation';

   static const String report =
      'Report';
  static const String reportTitle =
      'Nitrogen dioxide Measurement';
  static const String nameTitle = 'File name: ';
  static const String evaluateTitle = 'Analyte: ';
  static const String timeTitle = 'Duration of sampling (seconds): ';
  static const String dateTitle = 'Date/Time: ';

  static const String inputForm = 'Nitrogen Dioxide';
  static const String noti = 'Please fill the informations';
  static const String analyzTap = 'Point pick';
  static const String analyzAll = 'Overall result';
  static const String imageTitle = 'Photograph: ';
}

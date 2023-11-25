import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:ndss_mobile/utils/ColorConfig.dart';

import 'pages/InputPage/InputPage.dart';

final logger = Logger(
  printer: PrettyPrinter(),
);

final loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

class myApp extends StatelessWidget {
  const myApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      Logger.level = Level.nothing;
    } else {
      Logger.level = Level.debug;
    }
    return FutureBuilder(
        future: Init.instance.initialize(),
        builder: (context, snapshot) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "modern-ndss by Kitiyaporn T.",
            builder: BotToastInit(),
            navigatorObservers: [BotToastNavigatorObserver()],
            home: const MyHomePage(),
            theme: ThemeData(
                primarySwatch: ColorCode.appBarColor,
                textTheme: GoogleFonts.sarabunTextTheme()),
          );
        });
  }
}

class Init {
  Init._();

  static final instance = Init._();

  Future initialize() async {
    await Future.delayed(const Duration(seconds: 3));
  }
}

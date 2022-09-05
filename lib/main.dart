import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bricks_dvmatyun/feature/home/presentation/home_page.dart';

void main() {
  runZonedGuarded(
    () {
      runApp(const MyApp());
    },
    (error, stackTrace) {
      //log.wtf('Uncaught top-level app error', error, stackTrace);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      builder: (context, child) {
        final window = WidgetsBinding.instance.window;
        return MediaQuery(
          data: MediaQueryData.fromWindow(window).copyWith(
            textScaleFactor: window.textScaleFactor.clamp(0.75, 1),
          ),
          child: child!,
        );
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: GlobalKey<NavigatorState>(),
      home: const HomePage(),
    );
  }
}

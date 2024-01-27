import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mdg_fixasset/Const/colors.dart';
import 'package:mdg_fixasset/HomeScreen.dart';
import 'package:mdg_fixasset/Utils/CustomScrollBehavior.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void initState() {
    // Future.delayed(Duration.zero).then((finish) async {
    //   if (Platform.isWindows) {
    //     bool isFullScreen = await DesktopWindow.getFullScreen();
    //     await DesktopWindow.setFullScreen(isFullScreen);
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      title: 'MDG Fix Assets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colour.blue),
        useMaterial3: true,
      ),
      home: const HomeScree(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mdg_fixasset/HomeScreen.dart';
import 'package:mdg_fixasset/Utils/CustomScrollBehavior.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //scrollBehavior: MyCustomScrollBehavior(),
      title: 'MDG Fix Assets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScree(),
    );
  }
}

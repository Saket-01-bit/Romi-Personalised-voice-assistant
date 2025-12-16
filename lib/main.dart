import 'package:flutter/material.dart';
import 'package:romeo/home_page.dart';
import 'package:romeo/pallete.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Romeo',

      theme: ThemeData.light(useMaterial3: true).copyWith(
        appBarTheme: const AppBarTheme(backgroundColor: Pallete.whiteColor),
          scaffoldBackgroundColor: Pallete.whiteColor),
      home: const HomePage(),
    );
  }
}
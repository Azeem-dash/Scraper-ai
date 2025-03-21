import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_scrapping_project/ArticleScreen.dart';
import 'package:web_scrapping_project/features/articles/presentation/pages/ArticlePage.dart';
import 'package:web_scrapping_project/features/articles/presentation/pages/HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: AppBarTheme(iconTheme: IconThemeData(color: Colors.white))
      ),

      home: HomePage(),
    );
  }
}
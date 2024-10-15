import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/home_page.dart';
import 'pages/raporlar_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'İlçe ve Okul Listesi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      getPages: [
        GetPage(name: '/', page: () => HomePage()),
        GetPage(name: '/raporlar', page: () => RaporlarPage()),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:prova_pm26s/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prova PM26s - 2023',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

import 'package:camera_filter/first_page.dart';
import 'package:camera_filter/ripple_effect.dart';
import 'package:flutter/material.dart';

import 'camera_filters.dart';

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
      title: 'Camera Filter',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home:FirstPage(),
      // CameraScreenPlugin (
      //   onDone: (value){
      //     print(value);
      //   },
      // ),
    );
  }
}
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//     );
//   }
// }



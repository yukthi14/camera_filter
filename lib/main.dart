import 'package:camera_filter/homepage.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder:(context,orientation,deviceType){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Camera Filter',
          theme: ThemeData(

            primarySwatch: Colors.blue,
          ),
          home:const FirstPage(),
          // CameraScreenPlugin (
          //   onDone: (value){
          //     print(value);
          //   },
          // ),
        );
      }

    );
  }
}



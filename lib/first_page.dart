import 'package:camera_filter/camera_filters.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reels',style: TextStyle(fontSize: 24,color: Colors.black),),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.teal.shade100,

      body: Column(
        children: [
          Center(
            child: Padding(
              padding:  EdgeInsets.only(top: MediaQuery.of(context).size.height*0.8,),
              child: FloatingActionButton.extended(
                clipBehavior: Clip.antiAlias,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) =>  CameraScreenPlugin()));
                },
                // child: const Text("CAMERA",
                //   style: TextStyle(),
                label: const Text("CAMERA"),
                icon: const Icon(Icons.camera,),
                backgroundColor: Colors.teal.shade600,
              ),
            ),
          )
        ],
      ),
    );
  }
}

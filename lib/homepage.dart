import 'package:audioplayers/audioplayers.dart';
import 'package:blur/blur.dart';
import 'package:camera_filter/camera_filters.dart';
import 'package:camera_filter/constant.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with SingleTickerProviderStateMixin {



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: pageView(),
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        height:7.h,
        color: Colors.black,
        index: currentIndex,
        backgroundColor: Colors.white,
        items:  [
          Icon(
            Icons.home_rounded,
            size: 13.sp,
            color: Colors.white,
          ),
          Icon(
            Icons.person,
            color: Colors.white,
            size: 13.sp,
          ),
          Icon(
            Icons.add_circle_rounded,
            color: Colors.white,
            size: 13.sp,
          ),
          Icon(
            Icons.assistant,
            color: Colors.white,
            size: 13.sp,
          ),
          Icon(
            Icons.settings_suggest_rounded,
            color: Colors.white,
            size: 13.sp,
          ),
        ],
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
                context,
                CupertinoDialogRoute(
                    transitionDuration: const Duration(milliseconds: 900),
                    transitionBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    builder: (context) => CameraScreenPlugin(),
                    context: context));
          }

          setState(() {
            currentIndex = index;
          });
        },
      ),
    );

  }

  Widget pageView() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (currentIndex == 0) {
      return SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          "assets/video.gif",
          fit: BoxFit.fill,
        ),
      );
    } else if (currentIndex == 1) {
      return Container(
        width: width,
        height: height,
        color: Colors.yellow,
      );
    } else if (currentIndex == 3) {
      return Container(
        width: width,
        height: height,
        color: Colors.green,
      );
    } else {
      return Container(
        width: width,
        height: height,
        color: Colors.purpleAccent,
      );
    }
  }
}

import 'package:camera_filter/camera_filters.dart';
import 'package:camera_filter/constant.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glass/glass.dart';
import 'package:marquee/marquee.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageView(),
      backgroundColor: Colors.black,
      bottomNavigationBar: CurvedNavigationBar(
        height: MediaQuery.of(context).size.height * 0.07,
        color: Colors.black,
        index: currentIndex,
        backgroundColor: Colors.white,
        items: [
          Icon(
            Icons.home_rounded,
            size: MediaQuery.of(context).size.width * 0.04,
            color: Colors.white,
          ),
          Icon(
            Icons.person,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.04,
          ),
          Icon(
            Icons.add_circle_rounded,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.04,
          ),
          Icon(
            Icons.assistant,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.04,
          ),
          Icon(
            Icons.settings_suggest_rounded,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.04,
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
      return Stack(
        children: [
          SizedBox(
            width: width,
            height: height * 0.8,
            child: Image.asset(
              "assets/video.gif",
              fit: BoxFit.fill,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: height * 0.8,
            ),
            width: width * 0.2,
            height: height * 0.05,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey, width: 2),
                shape: BoxShape.circle,
                image: const DecorationImage(
                    image: AssetImage('assets/profile.jpg'))),
          ),

          //user
          Padding(
            padding: EdgeInsets.only(top: height * 0.825, left: width * 0.15),
            child: SizedBox(
              width: width * 0.2,
              height: height * 0.02,
              child: const Center(
                child: Text(
                  '@user',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ).asGlass(
                tintColor: Colors.transparent,
                clipBorderRadius: BorderRadius.circular(100.0)),
          ),

          //username
          Padding(
            padding: EdgeInsets.only(top: height * 0.806, left: width * 0.15),
            child: SizedBox(
              width: width * 0.2,
              height: height * 0.02,
              child: const Center(
                child: Text(
                  'UserName',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ).asGlass(
                tintColor: Colors.transparent,
                clipBorderRadius: BorderRadius.circular(100.0)),
          ),

          // Autograph
          Padding(
              padding: EdgeInsets.only(top: height * 0.808, left: height * 0.2),
              child: Container(
                width: width * 0.2,
                height: height * 0.025,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(5)),
                child: const Center(
                  child: Text(
                    'Autograph',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              )),
          //timer
          Padding(
              padding: EdgeInsets.only(top: height * 0.81, left: height * 0.3),
              child: Container(
                width: width * 0.1,
                height: height * 0.019,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(5)),
                child: const Center(
                  child: Text(
                    '00:13',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              )),
          //description
          Padding(
              padding: EdgeInsets.only(
                top: height * 0.86,
              ),
              child: Container(
                margin: EdgeInsets.only(left: width * 0.08),
                width: width,
                height: height * 0.025,
                child: const Text(
                  'Description',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              )),

          Padding(
            padding: EdgeInsets.only(top: height * 0.89, left: width * 0.07),
            child: Row(
              children: [
                Container(
                  height: height * 0.03,
                  width: width * 0.06,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      // shape: BoxShape.circle,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                          topRight: Radius.circular(2),
                          bottomLeft: Radius.circular(2)),
                      image: const DecorationImage(
                          image: AssetImage('assets/poster1.webp'))),
                ),
                SizedBox(
                        width: width * 0.8,
                        height: height * 0.02,
                        child: Marquee(
                          text: songName,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          blankSpace: 300,
                          velocity: 100,
                        )
                        // AnimatedTextKit(
                        //   repeatForever: true,
                        //   animatedTexts: [
                        //     TyperAnimatedText(songName,
                        //         textAlign: TextAlign.right,
                        //         speed: const Duration(milliseconds: 100),
                        //         textStyle: const TextStyle(color: Colors.white)),
                        //   ],
                        // ),
                        )
                    .asGlass(
                        tintColor: Colors.white,
                        clipBorderRadius: BorderRadius.circular(100.0)),
              ],
            ),
          ),
        ],
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

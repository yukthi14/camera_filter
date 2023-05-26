import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'constant.dart';

class PlayingVideo extends StatefulWidget {
  String? pathh;
  int index;

  @override
  _PlayingVideoState createState() => _PlayingVideoState();

  PlayingVideo({
    Key? key,
    required this.pathh, // Video from assets folder
    required this.index, // Video from assets folder
  }) : super(key: key);
}

class _PlayingVideoState extends State<PlayingVideo> {
  ValueNotifier<VideoPlayerValue?> currentPosition = ValueNotifier(null);
  VideoPlayerController? controller;
  late Future<void> futureController;

  initVideo() {
    controller = VideoPlayerController.asset(widget.pathh!);

    futureController = controller!.initialize();
  }

  @override
  void initState() {
    initVideo();
    controller!.addListener(() {
      if (controller!.value.isInitialized) {
        currentPosition.value = controller!.value;
      }
    });
    controller?.setLooping(true);
    controller?.play();
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureController,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (autoPlay) {
              Duration? durationTime = controller?.value.duration;
              Future.delayed(durationTime!).then((value) {
                setState(() {
                  newController.animateToPage(widget.index + 1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn);
                });
              });
            }
            return Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.04),
              height: MediaQuery.of(context).size.height * 0.95,
              child: AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VideoPlayer(controller!)),
            );
          }
        });
  }
}

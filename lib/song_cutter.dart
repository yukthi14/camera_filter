import 'package:audioplayers/audioplayers.dart';
import 'package:camera_filter/audio_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'constant.dart';

class SongCutter extends StatefulWidget {
  const SongCutter({Key? key, required this.value}) : super(key: key);
  final int value;

  @override
  State<SongCutter> createState() => _SongCutterState();
}

class _SongCutterState extends State<SongCutter> {
  final player = AudioPlayer();
  bool playing = false;

  @override
  void dispose() {
    // TODO: implement dispose
    player.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50))),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: Center(
                child: WaveSlider(
                  backgroundColor: Colors.black87,
                  heightWaveSlider: 80,
                  widthWaveSlider: 300,
                  duration: 12.0,
                  callbackStart: (duration) {
                    print("Start $duration");
                  },
                  callbackEnd: (duration) {
                    print("End $duration");
                  },
                ),
              ),
            ),
            // Container(
            //   margin: EdgeInsets.only(
            //       top: MediaQuery.of(context).size.height * 0.02),
            //   width: MediaQuery.of(context).size.width,
            //   height: MediaQuery.of(context).size.height * 0.05,
            //   child: Center(
            //     child: Text('',
            //       style: TextStyle(fontSize: 25, color: Colors.white),
            //     ),
            //   ),
            // ),
            Container(
              margin: EdgeInsets.only(
                top: 0.5.h,
              ),
              width: MediaQuery.of(context).size.width,
              child: Image.asset(posterImage[widget.value]),
            ),
            Padding(
              padding: EdgeInsets.only(top: 45.h),
              child: Center(
                child: MaterialButton(
                  onPressed: () async {
                    try {
                      if (!playing) {
                        await player.play(AssetSource(allSong[widget.value]));
                        setState(() => playing = true);
                      } else {
                        await player.pause();
                        setState(() => playing = false);
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print(e.toString());
                      }
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.height * 0.08,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white54,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white70,
                          offset: Offset(
                            1.0,
                            1.0,
                          ),
                          blurRadius: 10.0,
                          spreadRadius: 6.0,
                        ), //BoxShadow
                        BoxShadow(
                          color: Colors.white54,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                    ),
                    child: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

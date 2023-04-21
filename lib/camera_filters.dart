import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:camera_filter/constant.dart';
import 'package:camera_filter/src/edit_image_screen.dart';
import 'package:camera_filter/src/filters.dart';
import 'package:camera_filter/src/widgets/circularProgress.dart';
import 'package:camera_filter/videoPlayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glass/glass.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreenPlugin extends StatefulWidget {
  Function(dynamic)? onDone;

  Function(dynamic)? onVideoDone;

  List<Color>? filters;

  bool applyFilters;

  ValueNotifier<Color>? filterColor;

  List<Color>? gradientColors;

  Widget? profileIconWidget;

  Widget? sendButtonWidget;

  CameraScreenPlugin({Key? key,
    this.onDone,
    this.onVideoDone,
    this.filters,
    this.profileIconWidget,
    this.applyFilters = true,
    this.gradientColors,
    this.sendButtonWidget,
    this.filterColor})
      : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreenPlugin>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController controller;

  CameraController? _controller;

  Future<void>? _initializeControllerFuture;

  GetStorage sp = GetStorage();
  double zoomLevel = 1.0;

  ValueNotifier<int> flashCount = ValueNotifier(0);

  ValueNotifier<String> time = ValueNotifier("");

  bool capture = false;

  Timer? t;

  List<CameraDescription> cameras = [];

  /// bool to change picture to video or video to picture
  ValueNotifier<bool> cameraChange = ValueNotifier(false);

  AnimationController? _rotationController;
  double _rotation = 0;
  double _scale = 0.85;

  bool get _showWaves => !controller.isDismissed;

  void _updateRotation() {
    _rotation = (_rotationController!.value * 2) * pi;
    print("_rotation is $_rotation");
  }

  void _updateScale() {
    _scale = (controller.value * 0.2) + 0.85;
    print("scale is $_scale");
  }

  final _filters = [
    Colors.transparent,
    ...List.generate(
      Colors.primaries.length,
          (index) => Colors.primaries[(index) % Colors.primaries.length],
    )
  ];

  ///filter color notifier
  final _filterColor = ValueNotifier<Color>(Colors.transparent);

  ///filter color change function
  void _onFilterChanged(Color value) {
    setState(() {
      rippleEffect = true;
    });
    widget.filterColor == null
        ? _filterColor.value = value
        : widget.filterColor!.value = value;
    Future.delayed(const Duration(seconds: 2), () {
      rippleEffect = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3500),
    )
      ..addListener(() async {
        setState(_updateScale);
      });
    _rotationController =
    AnimationController(vsync: this, duration: Duration(seconds: 5))
      ..addListener(() {
        setState(_updateRotation);
        if (_rotation > 5) {
          _rotationController!.reset();
          _rotationController!.forward();
        }
      });

    super.initState();
    if (sp.read("flashCount") != null) {
      flashCount.value = sp.read("flashCount");
    }
    if (widget.filterColor != null) {
      widget.filterColor = ValueNotifier<Color>(Colors.transparent);
    }
    initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller!.dispose();
    super.dispose();
  }

  showInSnackBar(String error) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $error')));
  }

  timer() {
    t = Timer.periodic(const Duration(seconds: 1), (timer) {
      time.value = timer.tick.toString();
    });
  }

  String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return "$minutesStr:$secondsStr";
    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();

    cameras = await availableCameras();

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      _controller!.setFlashMode(FlashMode.off);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: _initializeControllerFuture == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned(
            bottom: MediaQuery
                .of(context)
                .size
                .height * 0.0001,
            top: MediaQuery
                .of(context)
                .size
                .height * 0.045,
            child: GestureDetector(
              onTap: () {
                if (zoomLevel == 8.0) {} else {
                  zoomLevel += 0.2;
                  _controller?.setZoomLevel(zoomLevel);
                }
              },
              onDoubleTap: () {
                if (zoomLevel == 1.0) {} else {
                  zoomLevel -= 0.2;
                  _controller?.setZoomLevel(zoomLevel);
                }
              },
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ValueListenableBuilder(
                        valueListenable: cameraChange,
                        builder: (context, value, Widget? c) {
                          return cameraChange.value == false
                              ? ValueListenableBuilder(
                              valueListenable:
                              widget.filterColor ?? _filterColor,
                              builder: (context, value, child) {
                                return ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                      widget.filterColor == null
                                          ? _filterColor.value
                                          : widget.filterColor!.value,
                                      BlendMode.softLight),
                                  child: CameraPreview(_controller!),
                                );
                              })
                              : CameraPreview(_controller!);
                        });
                  } else {
                    /// Otherwise, display a loading indicator.
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
          Positioned(
            top: 40.0,
            right: 10.0,
            child: ValueListenableBuilder(
                valueListenable: cameraChange,
                builder: (context, value, Widget? c) {
                  return cameraChange.value == false
                      ? Container()
                      : Text(
                    time.value == ""
                        ? ""
                        : formatHHMMSS(int.parse(time.value)),
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  );
                }),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: ValueListenableBuilder(
                valueListenable: cameraChange,
                builder: (context, value, Widget? c) {
                  return cameraChange.value == false
                      ? _buildFilterSelector()
                      : videoRecordingWidget();
                }),
          ),
          Positioned(
            right: 10.0,
            top: 30.0,
            child: widget.profileIconWidget ?? Container(),
          ),
          Positioned(
            left: MediaQuery
                .of(context)
                .size
                .width * 0.86,
            top: MediaQuery
                .of(context)
                .size
                .height * 0.05,
            child: Column(
              children: [
                /// icon for flash modes
                IconButton(
                  onPressed: () {
                    if (flashCount.value == 0) {
                      flashCount.value = 1;
                      sp.write("flashCount", 1);
                      _controller!.setFlashMode(FlashMode.torch);

                    } else if (flashCount.value == 1) {
                      flashCount.value = 2;
                      sp.write("flashCount", 2);
                      _controller!.setFlashMode(FlashMode.auto);
                    }

                    else {
                      flashCount.value = 0;
                      sp.write("flashCount", 0);
                      _controller!.setFlashMode(FlashMode.off);
                    }
                  },
                  icon: ValueListenableBuilder(
                      valueListenable: flashCount,
                      builder: (context, value, Widget? c) {
                        return Icon(
                          flashCount.value == 0
                              ? Icons.flash_off_rounded
                              : flashCount.value == 1
                              ? Icons.flash_on_rounded
                              : Icons.flash_auto_rounded,
                          color: Colors.white,
                        );
                      }),
                ),
                SizedBox(
                  width: 5,
                ),

                /// camera change to front or back
                IconButton(
                  icon: Icon(
                    Icons.cameraswitch_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_controller!.description.lensDirection ==
                        CameraLensDirection.front) {
                      final CameraDescription selectedCamera = cameras[0];
                      _initCameraController(selectedCamera);
                    } else {
                      final CameraDescription selectedCamera = cameras[1];
                      _initCameraController(selectedCamera);
                    }
                  },
                ),
                SizedBox(
                  width: 2,
                ),
                slide
                    ? ValueListenableBuilder(
                    valueListenable: cameraChange,
                    builder: (context, value, Widget? c) {
                      return IconButton(
                          icon: Icon(
                            cameraChange.value == false
                                ? Icons.videocam_rounded
                                : Icons.camera_alt_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (cameraChange.value == false) {
                              setState(() {
                                slowMotion = false;
                                slide = false;
                              });
                              cameraChange.value = true;
                              _controller!.prepareForVideoRecording();
                            } else {
                              setState(() {
                                slowMotion = false;
                                slide = false;
                              });
                              cameraChange.value = false;
                            }
                          });
                    })
                    : const SizedBox(),

                slide
                    ? IconButton(
                  onPressed: () {
                    showCupertinoModalPopup(context: context, builder: (BuildContext builder){
                      return CupertinoPopupSurface(
                        child:Container(
                        color: CupertinoColors.white,
                            alignment: Alignment.center,
                          width: double.infinity,
                          height:  MediaQuery
                              .of(context)
                              .size
                              .height * 0.6,
                        ),
                      );
                    });


                  },
                  color: Colors.white,
                  icon: const Icon(Icons.music_note_rounded),
                )
                    : const SizedBox(),

                slide
                    ? IconButton(
                  onPressed: () {
                    setState(() {
                      selectTimer = !selectTimer;
                    });
                  },
                  color: Colors.white,
                  icon: const Icon(Icons.timer_rounded),
                )
                    : const SizedBox(),

                slide
                    ? IconButton(
                  onPressed: () {},
                  color: Colors.white,
                  icon: const Icon(Icons.brightness_6_rounded),
                )
                    : const SizedBox(),

                slide
                    ? IconButton(
                  onPressed: () {},
                  color: Colors.white,
                  icon: const Icon(Icons.filter_alt_rounded),
                )
                    : const SizedBox(),
                (slide && cameraChange.value)
                    ? IconButton(
                  onPressed: () {
                   setState(() {
                     fps=!fps;
                   });
                  },
                  color: Colors.white,
                  icon: const Icon(Icons.slow_motion_video_rounded),
                )
                    : const SizedBox(),



                AnimatedContainer(
                    margin: EdgeInsets.only(top: slide ? 5 : 0),
                    duration: const Duration(milliseconds: 150),
                    child: IconButton(
                      icon: Icon(
                        slide
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          slide = !slide;
                          selectTimer = false;
                          slowMotion = false;
                          fps=false;
                        });
                      },
                    )),
              ],
            ).asGlass(
                tintColor: Colors.black,
                clipBorderRadius: BorderRadius.circular(100.0)),
          ),
          Positioned(
            left: MediaQuery
                .of(context)
                .size
                .width * 0.01,
            top: MediaQuery
                .of(context)
                .size
                .height * 0.05,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ).asGlass(
                    tintColor: Colors.black,
                    clipBorderRadius: BorderRadius.circular(100.0)

                ),
              ],
            ),
          ),
          Positioned(
            left: MediaQuery
                .of(context)
                .size
                .width * 0.6,
            top: MediaQuery
                .of(context)
                .size
                .height * 0.28,
            child: selectTimer
                ? Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.timer_10_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.timer_3_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ).asGlass(
                tintColor: Colors.black,
                clipBorderRadius: BorderRadius.circular(100.0))
                : const SizedBox(),
          ),

          Positioned(
            left: MediaQuery
                .of(context)
                .size
                .width * 0.6,
            top: MediaQuery
                .of(context)
                .size
                .height * 0.45,
            child:fps ? Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.sixty_fps_select_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.thirty_fps_select_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ).asGlass(
                tintColor: Colors.black,
                clipBorderRadius: BorderRadius.circular(100.0)):SizedBox(),
          ),

          Positioned(
              left: MediaQuery
                  .of(context)
                  .size
                  .width * 0.35,
              bottom: MediaQuery
                  .of(context)
                  .size
                  .height * 0.16,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (zoomLevel == 8.0) {} else {
                        zoomLevel += 0.2;
                        _controller?.setZoomLevel(zoomLevel);
                      }
                    },
                    child: SizedBox(
                      child: Center(
                          child: Text(
                            "0.6x",
                            style: TextStyle(color: Colors.white),
                          )),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.09,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.04,
                    ).asGlass(
                        tintColor: Colors.transparent,
                        clipBorderRadius: BorderRadius.circular(100.0)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    child: SizedBox(
                      child: Center(
                          child: Text(
                            "1x",
                            style: TextStyle(color: Colors.white),
                          )),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.09,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.04,
                    ).asGlass(
                        tintColor: Colors.transparent,
                        clipBorderRadius: BorderRadius.circular(50.0)),
                  ),
                  SizedBox(
                    child: Center(
                        child: Text(
                          "2x",
                          style: TextStyle(color: Colors.white),
                        )),
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.09,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.04,
                  ).asGlass(
                      tintColor: Colors.transparent,
                      clipBorderRadius: BorderRadius.circular(100.0)),
                ],
              )),


          Positioned(
              bottom: 120.0,
              child: Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: cameraChange,
                    builder: (BuildContext context, bool value,
                        Widget? child) {
                      return IconButton(
                          icon: Icon(
                            cameraChange.value == false
                                ? Icons.photo_album_outlined
                                : Icons.video_camera_front,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () async {
                            if (cameraChange.value == false) {
                              ImagePicker image = ImagePicker();
                              try {
                                XFile? filePath =
                                await image.pickImage(
                                    source: ImageSource.gallery);
                                print(filePath);
                              } catch (e) {
                                print(e);
                              }
                            } else {
                              ImagePicker image = ImagePicker();
                              try {
                                XFile? filePath =
                                await image.pickVideo(
                                    source: ImageSource.gallery);
                                print(filePath);
                              } catch (e) {
                                print(e);
                              }
                            }
                          })
                          .asGlass(
                          tintColor: Colors.black,
                          clipBorderRadius: const BorderRadius.only(
                              topRight: Radius.circular(100),
                              bottomRight: Radius.circular(100)));
                    },
                  )
                ],
              )),

        ],
      ),
    );
  }

  flashCheck() {
    if (sp.read("flashCount") == 1) {
      _controller!.setFlashMode(FlashMode.off);
    }
  }

  void onTakePictureButtonPressed(context) {
    takePicture(context).then((String? filePath) async {
      if (_controller!.value.isInitialized) {
        if (filePath != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditImageScreen(
                      path: filePath,
                      applyFilters: widget.applyFilters,
                      sendButtonWidget: widget.sendButtonWidget,
                      filter: ColorFilter.mode(
                          widget.filterColor == null
                              ? _filterColor.value
                              : widget.filterColor!.value,
                          BlendMode.softLight),
                      onDone: widget.onDone,
                    )),
          ).then((value) {
            if (sp.read("flashCount") == 1) {
              _controller!.setFlashMode(FlashMode.torch);
            }
          });
          flashCheck();
        }
      }
    });
  }

  Future<String> takePicture(context) async {
    if (!_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: camera is not initialized')));
    }
    final dirPath = await getTemporaryDirectory();
    String filePath = '${dirPath.path}/${timestamp()}.jpg';

    try {
      final picture = await _controller!.takePicture();
      filePath = picture.path;
    } on CameraException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.description}')));
    }
    return filePath;
  }

  String timestamp() =>
      DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();

  /// widget will build the filter selector
  Widget _buildFilterSelector() {
    return FilterSelector(
      onFilterChanged: _onFilterChanged,
      filters: widget.applyFilters == false ? [] : widget.filters ?? _filters,
      onTap: () {
        if (capture == false) {
          capture = true;
          onTakePictureButtonPressed(context);
          Future.delayed(const Duration(seconds: 3), () {
            capture = false;
          });
        }
      },
    );
  }

  Future _initCameraController(CameraDescription cameraDescription) async {

    _controller = CameraController(cameraDescription, ResolutionPreset.high);

    _controller!.addListener(() {

      if (_controller!.value.hasError) {
        print('Camera error ${_controller!.value.errorDescription}');
      }
    });

    try {
      await _controller!.initialize();
    } on CameraException catch (e) {
      print(e);
    }
    setState(() {});
  }

  ///video recording function
  Widget videoRecordingWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onLongPress: () async {
          // if(controller.value ){

          await _controller!.prepareForVideoRecording();
          await _controller!.startVideoRecording();
          timer();
          controller.forward();
          _rotationController!.forward();
          // }
        },
        onLongPressEnd: (v) async {
          t!.cancel();
          time.value = "";
          controller.reset();
          _rotationController!.reset();
          final file = await _controller!.stopVideoRecording();
          flashCheck();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VideoPlayer(
                      file.path,
                      applyFilters: widget.applyFilters,
                      onVideoDone: widget.onVideoDone,
                      sendButtonWidget: widget.sendButtonWidget,
                    )),
          ).then((value) {
            if (sp.read("flashCount") == 1) {
              _controller!.setFlashMode(FlashMode.torch);
            }
          });
        },
        child: SizedBox(
          width: 70,
          height: 70,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (_showWaves) ...[
                  Blob(
                      color: const Color(0xff0092ff),
                      scale: _scale,
                      rotation: _rotation),
                  Blob(
                      color: const Color(0xff4ac7b7),
                      scale: _scale,
                      rotation: _rotation * 2 - 30),
                  Blob(
                      color: const Color(0xffa4a6f6),
                      scale: _scale,
                      rotation: _rotation * 3 - 45),
                ],
                Container(
                  constraints: const BoxConstraints.expand(),
                  child: AnimatedSwitcher(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          color: Color(0xffd51820),
                          borderRadius: BorderRadius.circular(100)),
                    ).asGlass(
                        tintColor: Colors.transparent,
                        clipBorderRadius: BorderRadius.circular(100.0)),
                    duration: Duration(milliseconds: 300),
                  ),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

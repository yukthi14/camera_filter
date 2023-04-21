import 'dart:io';
import 'package:camera_filter/src/draw_image.dart';
import 'package:camera_filter/src/painter.dart';
import 'package:camera_filter/src/tapioca/content.dart';
import 'package:camera_filter/src/tapioca/tapioca_ball.dart';
import 'package:camera_filter/src/widgets/_range_slider.dart';
import 'package:camera_filter/src/widgets/progressDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:glass/glass.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart' as video;
import 'package:video_player/video_player.dart';

import 'src/tapioca/cup.dart';

class VideoPlayer extends StatefulWidget {
  String? video;
  Widget? sendButtonWidget;
  bool applyFilters;
  Function(dynamic)? onVideoDone;

  VideoPlayer(this.video,
      {this.onVideoDone, this.sendButtonWidget, this.applyFilters = true});

  @override
  State<VideoPlayer> createState() => _VideoPlayersState();
}

late VideoPlayerController _videoPlayerController;

class _VideoPlayersState extends State<VideoPlayer> {
  late TextDelegate textDelegate;
  late final ValueNotifier<Controller> _controller;
  final TextEditingController _textEditingController = TextEditingController();
  double fontSize = 30;
  ValueNotifier<bool> dragText = ValueNotifier(false);
  ValueNotifier<bool> textFieldBool = ValueNotifier(false);
  Offset offset = Offset.zero;

  String text = '';
  ValueNotifier<int> colorValue = ValueNotifier(0xFFFFFFFF);

  ///list of filters color
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
    _filterColor.value = value;
  }

  ProgressDialog? progressDialog;

  /// widget will build the filter selector
  Widget _buildFilterSelector() {
    int index = 0;
    return Center(
      child: Container(
        height: 50,
        child: PageView.builder(
          itemCount: _filters.length,
          onPageChanged: (i) {
            index = i;
            print("index is " + index.toString());
          },
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, position) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          if (index != 0) {
                            _onFilterChanged(_filters[index - 1]);
                            index = index - 1;
                          }
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        )),
                    const Spacer(),
                    GestureDetector(
                        onTap: () {
                          if (index != _filters.length - 1) {
                            _onFilterChanged(_filters[index + 1]);
                            index = index + 1;
                          }
                        },
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    progressDialog = ProgressDialog(context);
    _controller = ValueNotifier(const Controller().copyWith(
        mode: PaintMode.freeStyle, strokeWidth: 2, color: Colors.white));
    textDelegate = TextDelegate();
    _videoPlayerController = VideoPlayerController.file(File(widget.video!));

    _videoPlayerController.addListener(() {
    });
    _videoPlayerController.setLooping(true);
    _videoPlayerController.initialize().then((_) => setState(() {}));
    _videoPlayerController.play();

    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: AspectRatio(
                aspectRatio: 0.5,
                child: ValueListenableBuilder(
                    valueListenable: _filterColor,
                    builder: (context, value, child) {
                      return ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            _filterColor.value, BlendMode.softLight),
                        child: video.VideoPlayer(_videoPlayerController),
                      );
                    })),
          ),
          ValueListenableBuilder(
              valueListenable: dragText,
              builder: (context, bool value, Widget? child) {
                if (value == false) {
                  return Container();
                } else {
                  return positionedText();
                }
              }),
          widget.applyFilters == false ? Container() : _buildFilterSelector(),
          widget.applyFilters == false
              ? Container()
              : Positioned(
                  top: 40,
                  right: 10,
                  child: Column(
                    children: [
                      PopupMenuButton(
                        tooltip: textDelegate.changeBrushSize,
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        icon: const Icon(Icons.format_size, color: Colors.white),
                        itemBuilder: (_) => [_showTextSlider()],
                      ),
                      ValueListenableBuilder<Controller>(
                          valueListenable: _controller,
                          builder: (_, controller, __) {
                            return IconButton(
                              icon: const Icon(
                                Icons.color_lens_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                colorPicker(controller);
                              },
                            );
                          }),
                      IconButton(
                          icon: const Icon(
                            Icons.text_format,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                enableDrag: true,
                                isDismissible: true,
                                builder: (builder) {
                                  return textField(context);
                                });
                          }),
                    ],
                  ).asGlass(
                      tintColor: Colors.black,
                      clipBorderRadius: BorderRadius.circular(100.0)),
          ),
          Positioned(
              bottom: 10,
              right: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Material(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      var tempDir = await getTemporaryDirectory();
                      final path =
                          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}result.mp4';

                      try {
                        var a = 1.7 * int.parse(xPos.toString().split(".")[0]);
                        var b = 1.7 * int.parse(yPos.toString().split(".")[0]);

                        if (text == "" && _filterColor.value.value == 0) {
                          widget.onVideoDone!.call(widget.video);
                        } else if (text == "" &&
                            _filterColor.value.value != 0) {
                          final tapiocaBalls = [
                            TapiocaBall.filterFromColor(
                                Color(_filterColor.value.value)),
                          ];
                          makeVideo(tapiocaBalls, path);
                        } else if (text != "" &&
                            _filterColor.value.value == 0) {
                          final tapiocaBalls = [
                            TapiocaBall.textOverlay(
                                text,
                                int.parse(a.toString().split(".")[0]),
                                int.parse(b.toString().split(".")[0]),
                                (fontSize * 2).toInt(),
                                Color(colorValue.value))
                          ];
                          makeVideo(tapiocaBalls, path);
                        } else {
                          final tapiocaBalls = [
                            TapiocaBall.filterFromColor(
                                Color(_filterColor.value.value)),
                            TapiocaBall.textOverlay(
                                text,
                                int.parse(a.toString().split(".")[0]),
                                int.parse(b.toString().split(".")[0]),
                                (fontSize * 2).toInt(),
                                Color(colorValue.value))
                          ];
                          makeVideo(tapiocaBalls, path);
                        }
                      } on PlatformException {
                        print("error!!!!");
                      }
                    },
                    child: widget.sendButtonWidget ??
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              color: const Color(0xffd51820),
                              borderRadius: BorderRadius.circular(60)),
                          child: const Center(
                            child: Icon(Icons.send),
                          ),
                        ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  makeVideo(tapiocaBalls, path) {
    progressDialog!.show();
    final cup = Cup(Content(widget.video!), tapiocaBalls);
    cup.suckUp(path).then((_) async {
      print("finished");
      progressDialog!.hide();
      widget.onVideoDone!.call(path);
    });
  }

  PopupMenuItem _showTextSlider() {
    return PopupMenuItem(
      enabled: false,
      child: SizedBox(
        width: double.maxFinite,
        child: ValueListenableBuilder<Controller>(
          valueListenable: _controller,
          builder: (_, ctrl, __) {
            return FontVideoRangedSlider(
                value: fontSize,
                onChanged: (value) {
                  _controller.value = ctrl.copyWith(fontSize: value);
                  fontSize = value;
                  setState(() {});
                });
          },
        ),
      ),
    );
  }

  colorPicker(controller) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: Color(controller.color.value),
                onColorChanged: (color) {
                  _controller.value = controller.copyWith(color: color);
                  colorValue.value = color.value;
                },
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Widget textField(context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 10,
          right: 10),
      child: Container(
        height: 55,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0.0, horizontal: 3),
                  child: TextFormField(
                      cursorColor: Colors.black,
                      autofocus: true,
                      controller: _textEditingController,
                      style: const TextStyle(color: Colors.black, fontSize: 25),
                      decoration: InputDecoration(border: InputBorder.none))),
            ),
            IconButton(
                onPressed: () {
                  if (_textEditingController.text.isNotEmpty) {
                    text = _textEditingController.text;
                    Navigator.pop(context);
                    dragText.value = true;
                  }
                },
                icon: const Icon(
                  Icons.send,
                  color: Colors.black,
                ))
          ],
        ),
      ),
    );
  }

  var xPos = 30.0;
  var yPos = 30.0;
  final width = 100.0;
  final height = 100.0;


  Widget positionedText() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          xPos += details.delta.dx;
          yPos += details.delta.dy;
        });
      },
      child: ValueListenableBuilder(
          valueListenable: colorValue,
          builder: (context, int value, Widget? child) {
            return CustomPaint(
              willChange: true,
              size: Size(
                MediaQuery.of(context).size.width,
                300,
              ),
              painter: MyPainter(
                  xPos, yPos, text, Color(colorValue.value), fontSize),
              child: Container(),
            );
          }),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter(this.xPos, this.yPos, this.text, this.color, this.fontSize);

  double? xPos;
  double? yPos;
  double? fontSize;
  String? text;
  Color? color;
  Offset? offset;
  TextPainter? textPainter;
  TextSpan? textSpan;
  TextStyle? textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
    );
    textSpan = TextSpan(
      text: '$text',
      style: textStyle,
    );
    textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter!.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    offset = Offset(xPos!, yPos!);
    textPainter!.paint(canvas, offset!);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

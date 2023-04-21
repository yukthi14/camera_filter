import 'package:camera_filter/src/painter.dart';
import 'package:flutter/material.dart';

class TextDialog extends StatelessWidget {
  const TextDialog(
      {Key? key,
      required this.controller,
      required this.fontSize,
      required this.onFinished,
      required this.color,
      required this.textDelegate})
      : super(key: key);

  final TextEditingController controller;

  /// font size of text put on image
  final double fontSize;

  /// call when you done
  final VoidCallback onFinished;

  /// color of text put on image
  final Color color;
  final TextDelegate textDelegate;
  static void show(BuildContext context, TextEditingController controller,
      double fontSize, Color color, TextDelegate textDelegate,
      {required ValueChanged<BuildContext> onFinished}) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        builder: (builder) {
          return TextDialog(
            controller: controller,
            fontSize: fontSize,
            onFinished: () => onFinished(context),
            color: color,
            textDelegate: textDelegate,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Material(color: Colors.transparent, child: textField(context)
        );
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
                      controller: controller,
                      style: const TextStyle(color: Colors.black, fontSize: 25),
                      decoration: InputDecoration(border: InputBorder.none))),
            ),
            IconButton(
                onPressed: onFinished,
                icon: const Icon(
                  Icons.send,
                  color: Colors.black,
                ))
          ],
        ),
      ),
    );
  }
}

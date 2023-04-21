import 'content.dart';
import 'tapioca_ball.dart';
import 'video_editor.dart';

class Cup {
  final Content content;

  final List<TapiocaBall> tapiocaBalls;

  /// Creates a Cup object.
  Cup(this.content, this.tapiocaBalls);

  Future suckUp(String destFilePath) {
    final Map<String, Map<String, dynamic>> processing = Map.fromIterable(
        tapiocaBalls,
        key: (v) => v.toTypeName(),
        value: (v) => v.toMap());
    return VideoEditor.writeVideofile(content.name, destFilePath, processing);
  }
}

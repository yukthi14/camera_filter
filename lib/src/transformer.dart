import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart' hide InteractiveViewer;
import 'package:vector_math/vector_math_64.dart' show Quad, Vector3, Matrix4;

@immutable
class ImagePainterTransformer extends StatefulWidget {
  ImagePainterTransformer({
    Key? key,
    this.alignPanAxis = false,
    this.boundaryMargin = EdgeInsets.zero,
    this.constrained = true,


    this.maxScale = 2.5,
    this.minScale = 0.8,
    this.onInteractionEnd,
    this.onInteractionStart,
    this.onInteractionUpdate,
    this.panEnabled = true,
    this.scaleEnabled = true,
    this.transformationController,
    required this.child,
  })  : assert(minScale > 0),
        assert(minScale.isFinite),
        assert(maxScale > 0),
        assert(!maxScale.isNaN),
        assert(maxScale >= minScale),

        assert((boundaryMargin.horizontal.isInfinite &&
                boundaryMargin.vertical.isInfinite) ||
            (boundaryMargin.top.isFinite &&
                boundaryMargin.right.isFinite &&
                boundaryMargin.bottom.isFinite &&
                boundaryMargin.left.isFinite)),
        super(key: key);

  final bool alignPanAxis;

  final EdgeInsets boundaryMargin;

  final Widget child;


  final bool constrained;


  final bool panEnabled;

  final bool scaleEnabled;


  final double maxScale;


  final double minScale;


  final GestureScaleEndCallback? onInteractionEnd;


  final GestureScaleStartCallback? onInteractionStart;


  final GestureScaleUpdateCallback? onInteractionUpdate;

  final TransformationController? transformationController;

  /// Returns the closest point to the given point on the given line segment.
  @visibleForTesting
  static Vector3 getNearestPointOnLine(Vector3 point, Vector3 l1, Vector3 l2) {
    final lengthSquared = math.pow(l2.x - l1.x, 2.0).toDouble() +
        math.pow(l2.y - l1.y, 2.0).toDouble();

    if (lengthSquared == 0) {
      return l1;
    }


    final l1P = point - l1;
    final l1L2 = l2 - l1;
    final fraction = (l1P.dot(l1L2) / lengthSquared).clamp(0.0, 1.0).toDouble();
    return l1 + l1L2 * fraction;
  }

  /// Given a quad, return its axis aligned bounding box.
  @visibleForTesting
  static Quad getAxisAlignedBoundingBox(Quad quad) {
    final minX = math.min(
      quad.point0.x,
      math.min(
        quad.point1.x,
        math.min(
          quad.point2.x,
          quad.point3.x,
        ),
      ),
    );
    final minY = math.min(
      quad.point0.y,
      math.min(
        quad.point1.y,
        math.min(
          quad.point2.y,
          quad.point3.y,
        ),
      ),
    );
    final maxX = math.max(
      quad.point0.x,
      math.max(
        quad.point1.x,
        math.max(
          quad.point2.x,
          quad.point3.x,
        ),
      ),
    );
    final maxY = math.max(
      quad.point0.y,
      math.max(
        quad.point1.y,
        math.max(
          quad.point2.y,
          quad.point3.y,
        ),
      ),
    );
    return Quad.points(
      Vector3(minX, minY, 0),
      Vector3(maxX, minY, 0),
      Vector3(maxX, maxY, 0),
      Vector3(minX, maxY, 0),
    );
  }

  @visibleForTesting
  static bool pointIsInside(Vector3 point, Quad quad) {
    final aM = point - quad.point0;
    final aB = quad.point1 - quad.point0;
    final aD = quad.point3 - quad.point0;

    final aMAB = aM.dot(aB);
    final aBAB = aB.dot(aB);
    final aMAD = aM.dot(aD);
    final aDAD = aD.dot(aD);

    return 0 <= aMAB && aMAB <= aBAB && 0 <= aMAD && aMAD <= aDAD;
  }


  @visibleForTesting
  static Vector3? getNearestPointInside(Vector3 point, Quad quad) {

    if (pointIsInside(point, quad)) {
      return point;
    }

    // Otherwise, return the nearest point on the quad.
    final closestPoints = <Vector3>[
      ImagePainterTransformer.getNearestPointOnLine(
          point, quad.point0, quad.point1),
      ImagePainterTransformer.getNearestPointOnLine(
          point, quad.point1, quad.point2),
      ImagePainterTransformer.getNearestPointOnLine(
          point, quad.point2, quad.point3),
      ImagePainterTransformer.getNearestPointOnLine(
          point, quad.point3, quad.point0),
    ];
    var minDistance = double.infinity;
    Vector3? closestOverall;
    for (final closePoint in closestPoints) {
      final distance = math.sqrt(
        math.pow(point.x - closePoint.x, 2) +
            math.pow(point.y - closePoint.y, 2),
      );
      if (distance < minDistance) {
        minDistance = distance;
        closestOverall = closePoint;
      }
    }
    return closestOverall;
  }

  @override
  _ImagePainterTransformerState createState() =>
      _ImagePainterTransformerState();
}

class _ImagePainterTransformerState extends State<ImagePainterTransformer>
    with TickerProviderStateMixin {
  TransformationController? _transformationController;

  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _parentKey = GlobalKey();
  Animation<Offset>? _animation;
  late AnimationController _controller;
  Axis? _panAxis;

  /// Used with alignPanAxis.
  Offset? _referenceFocalPoint;

  /// Point where the current gesture began.
  double? _scaleStart;

  /// Scale value at start of scaling gesture.
  double? _rotationStart = 0.0;

  /// Rotation at start of rotation gesture.
  double _currentRotation = 0.0;

  /// Rotation of _transformationController.value.
  _GestureType? _gestureType;

  final bool _rotateEnabled = false;


  static const double _kDrag = 0.0000135;

  Rect get _boundaryRect {
    assert(_childKey.currentContext != null);
    assert(!widget.boundaryMargin.left.isNaN);
    assert(!widget.boundaryMargin.right.isNaN);
    assert(!widget.boundaryMargin.top.isNaN);
    assert(!widget.boundaryMargin.bottom.isNaN);

    final childRenderBox =
        _childKey.currentContext!.findRenderObject() as RenderBox;
    final childSize = childRenderBox.size;
    final boundaryRect =
        widget.boundaryMargin.inflateRect(Offset.zero & childSize);


    assert(
        boundaryRect.isFinite ||
            (boundaryRect.left.isInfinite &&
                boundaryRect.top.isInfinite &&
                boundaryRect.right.isInfinite &&
                boundaryRect.bottom.isInfinite),
        'boundaryRect must either be infinite in all directions or finite in all directions.');
    return boundaryRect;
  }

  /// The Rect representing the child's parent.
  Rect get _viewport {
    assert(_parentKey.currentContext != null);
    final parentRenderBox =
        _parentKey.currentContext!.findRenderObject() as RenderBox;
    return Offset.zero & parentRenderBox.size;
  }


  Matrix4 _matrixTranslate(Matrix4 matrix, Offset translation) {
    if (translation == Offset.zero) {
      return matrix.clone();
    }

    final alignedTranslation = widget.alignPanAxis && _panAxis != null
        ? _alignAxis(translation, _panAxis)
        : translation;

    final nextMatrix = matrix.clone()
      ..translate(
        alignedTranslation.dx,
        alignedTranslation.dy,
      );


    final nextViewport = _transformViewport(nextMatrix, _viewport);

    if (_boundaryRect.isInfinite) {
      return nextMatrix;
    }


    final boundariesAabbQuad = _getAxisAlignedBoundingBoxWithRotation(
      _boundaryRect,
      _currentRotation,
    );

    final offendingDistance = _exceedsBy(boundariesAabbQuad, nextViewport);
    if (offendingDistance == Offset.zero) {
      return nextMatrix;
    }

    final nextTotalTranslation = _getMatrixTranslation(nextMatrix);
    final currentScale = matrix.getMaxScaleOnAxis();
    final correctedTotalTranslation = Offset(
      nextTotalTranslation.dx - offendingDistance.dx * currentScale,
      nextTotalTranslation.dy - offendingDistance.dy * currentScale,
    );

    final correctedMatrix = matrix.clone()
      ..setTranslation(Vector3(
        correctedTotalTranslation.dx,
        correctedTotalTranslation.dy,
        0.0,
      ));

    /// Double check that the corrected translation fits.
    final correctedViewport = _transformViewport(correctedMatrix, _viewport);
    final offendingCorrectedDistance =
        _exceedsBy(boundariesAabbQuad, correctedViewport);
    if (offendingCorrectedDistance == Offset.zero) {
      return correctedMatrix;
    }

    if (offendingCorrectedDistance.dx != 0.0 &&
        offendingCorrectedDistance.dy != 0.0) {
      return matrix.clone();
    }

    final unidirectionalCorrectedTotalTranslation = Offset(
      offendingCorrectedDistance.dx == 0.0 ? correctedTotalTranslation.dx : 0.0,
      offendingCorrectedDistance.dy == 0.0 ? correctedTotalTranslation.dy : 0.0,
    );
    return matrix.clone()
      ..setTranslation(Vector3(
        unidirectionalCorrectedTotalTranslation.dx,
        unidirectionalCorrectedTotalTranslation.dy,
        0.0,
      ));
  }


  Matrix4 _matrixScale(Matrix4 matrix, double scale) {
    if (scale == 1.0) {
      return matrix.clone();
    }
    assert(scale != 0.0);


    final currentScale = _transformationController!.value.getMaxScaleOnAxis();
    final totalScale = currentScale * scale;
    final clampedTotalScale = totalScale.clamp(
      widget.minScale,
      widget.maxScale,
    );
    final clampedScale = clampedTotalScale / currentScale;
    final nextMatrix = matrix.clone()..scale(clampedScale);


    final minScale = math.max(
      _viewport.width / _boundaryRect.width,
      _viewport.height / _boundaryRect.height,
    );
    if (clampedTotalScale < minScale) {
      final minCurrentScale = minScale / currentScale;
      return matrix.clone()..scale(minCurrentScale);
    }

    return nextMatrix;
  }


  Matrix4 _matrixRotate(Matrix4 matrix, double rotation, Offset focalPoint) {
    if (rotation == 0) {
      return matrix.clone();
    }
    final focalPointScene = _transformationController!.toScene(
      focalPoint,
    );
    return matrix.clone()
      ..translate(focalPointScene.dx, focalPointScene.dy)
      ..rotateZ(-rotation)
      ..translate(-focalPointScene.dx, -focalPointScene.dy);
  }

  bool _gestureIsSupported(_GestureType? gestureType) {
    switch (gestureType) {
      case _GestureType.rotate:
        return _rotateEnabled;

      case _GestureType.scale:
        return widget.scaleEnabled;

      case _GestureType.pan:
      default:
        return widget.panEnabled;
    }
  }


  _GestureType _getGestureType(ScaleUpdateDetails details) {
    final scale = !widget.scaleEnabled ? 1.0 : details.scale;
    final rotation = !_rotateEnabled ? 0.0 : details.rotation;
    if ((scale - 1).abs() > rotation.abs()) {
      return _GestureType.scale;
    } else if (rotation != 0.0) {
      return _GestureType.rotate;
    } else {
      return _GestureType.pan;
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (widget.onInteractionStart != null) {
      widget.onInteractionStart!(details);
    }

    if (_controller.isAnimating) {
      _controller.stop();
      _controller.reset();
      _animation?.removeListener(_onAnimate);
      _animation = null;
    }

    _gestureType = null;
    _panAxis = null;
    _scaleStart = _transformationController!.value.getMaxScaleOnAxis();
    _referenceFocalPoint = _transformationController!.toScene(
      details.localFocalPoint,
    );
    _rotationStart = _currentRotation;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final scale = _transformationController!.value.getMaxScaleOnAxis();
    if (widget.onInteractionUpdate != null) {
      widget.onInteractionUpdate!(ScaleUpdateDetails(
        focalPoint: _transformationController!.toScene(
          details.localFocalPoint,
        ),
        scale: details.scale,
        rotation: details.rotation,
      ));
    }
    final focalPointScene = _transformationController!.toScene(
      details.localFocalPoint,
    );

    if (_gestureType == _GestureType.pan) {

      _gestureType = _getGestureType(details);
    } else {
      _gestureType ??= _getGestureType(details);
    }
    if (!_gestureIsSupported(_gestureType)) {
      return;
    }

    switch (_gestureType!) {
      case _GestureType.scale:
        assert(_scaleStart != null);


        final desiredScale = _scaleStart! * details.scale;
        final scaleChange = desiredScale / scale;
        _transformationController!.value = _matrixScale(
          _transformationController!.value,
          scaleChange,
        );


        final focalPointSceneScaled = _transformationController!.toScene(
          details.localFocalPoint,
        );
        _transformationController!.value = _matrixTranslate(
          _transformationController!.value,
          focalPointSceneScaled - _referenceFocalPoint!,
        );


        final focalPointSceneCheck = _transformationController!.toScene(
          details.localFocalPoint,
        );
        if (_round(_referenceFocalPoint!) != _round(focalPointSceneCheck)) {
          _referenceFocalPoint = focalPointSceneCheck;
        }
        return;

      case _GestureType.rotate:
        if (details.rotation == 0.0) {
          return;
        }
        final desiredRotation = _rotationStart! + details.rotation;
        _transformationController!.value = _matrixRotate(
          _transformationController!.value,
          _currentRotation - desiredRotation,
          details.localFocalPoint,
        );
        _currentRotation = desiredRotation;
        return;

      case _GestureType.pan:
        assert(_referenceFocalPoint != null);


        if (details.scale != 1.0) {
          return;
        }
        _panAxis ??= _getPanAxis(_referenceFocalPoint, focalPointScene);


        final translationChange = focalPointScene - _referenceFocalPoint!;
        _transformationController!.value = _matrixTranslate(
          _transformationController!.value,
          translationChange,
        );
        _referenceFocalPoint = _transformationController!.toScene(
          details.localFocalPoint,
        );
        return;
    }
  }


  void _onScaleEnd(ScaleEndDetails details) {
    if (widget.onInteractionEnd != null) {
      widget.onInteractionEnd!(details);
    }
    _scaleStart = null;
    _rotationStart = null;
    _referenceFocalPoint = null;

    _animation?.removeListener(_onAnimate);
    _controller.reset();

    if (!_gestureIsSupported(_gestureType)) {
      _panAxis = null;
      return;
    }

    /// If the scale ended with enough velocity, animate inertial movement.
    if (_gestureType != _GestureType.pan ||
        details.velocity.pixelsPerSecond.distance < kMinFlingVelocity) {
      _panAxis = null;
      return;
    }

    final translationVector = _transformationController!.value.getTranslation();
    final translation = Offset(translationVector.x, translationVector.y);
    final frictionSimulationX = FrictionSimulation(
      _kDrag,
      translation.dx,
      details.velocity.pixelsPerSecond.dx,
    );
    final frictionSimulationY = FrictionSimulation(
      _kDrag,
      translation.dy,
      details.velocity.pixelsPerSecond.dy,
    );
    final tFinal = _getFinalTime(
      details.velocity.pixelsPerSecond.distance,
      _kDrag,
    );
    _animation = Tween<Offset>(
      begin: translation,
      end: Offset(frictionSimulationX.finalX, frictionSimulationY.finalX),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    ));
    _controller.duration = Duration(milliseconds: (tFinal * 1000).round());
    _animation!.addListener(_onAnimate);
    _controller.forward();
  }

  void _receivedPointerSignal(PointerSignalEvent event) {
    if (!_gestureIsSupported(_GestureType.scale)) {
      return;
    }
    if (event is PointerScrollEvent) {
      final childRenderBox =
          _childKey.currentContext!.findRenderObject() as RenderBox;
      final childSize = childRenderBox.size;
      final scaleChange = 1.0 - event.scrollDelta.dy / childSize.height;
      if (scaleChange == 0.0) {
        return;
      }
      final focalPointScene = _transformationController!.toScene(
        event.localPosition,
      );
      _transformationController!.value = _matrixScale(
        _transformationController!.value,
        scaleChange,
      );


      final focalPointSceneScaled = _transformationController!.toScene(
        event.localPosition,
      );
      _transformationController!.value = _matrixTranslate(
        _transformationController!.value,
        focalPointSceneScaled - focalPointScene,
      );
    }
  }

  void _onAnimate() {
    if (!_controller.isAnimating) {
      _panAxis = null;
      _animation?.removeListener(_onAnimate);
      _animation = null;
      _controller.reset();
      return;
    }

    final translationVector = _transformationController!.value.getTranslation();
    final translation = Offset(translationVector.x, translationVector.y);
    final translationScene = _transformationController!.toScene(
      translation,
    );
    final animationScene = _transformationController!.toScene(
      _animation!.value,
    );
    final translationChangeScene = animationScene - translationScene;
    _transformationController!.value = _matrixTranslate(
      _transformationController!.value,
      translationChangeScene,
    );
  }

  void _onTransformationControllerChange() {

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _transformationController =
        widget.transformationController ?? TransformationController();
    _transformationController!.addListener(_onTransformationControllerChange);
    _controller = AnimationController(
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ImagePainterTransformer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.transformationController == null) {
      if (widget.transformationController != null) {
        _transformationController!
            .removeListener(_onTransformationControllerChange);
        _transformationController!.dispose();
        _transformationController = widget.transformationController;
        _transformationController!
            .addListener(_onTransformationControllerChange);
      }
    } else {
      if (widget.transformationController == null) {
        _transformationController!
            .removeListener(_onTransformationControllerChange);
        _transformationController = TransformationController();
        _transformationController!
            .addListener(_onTransformationControllerChange);
      } else if (widget.transformationController !=
          oldWidget.transformationController) {
        _transformationController!
            .removeListener(_onTransformationControllerChange);
        _transformationController = widget.transformationController;
        _transformationController!
            .addListener(_onTransformationControllerChange);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _transformationController!
        .removeListener(_onTransformationControllerChange);
    if (widget.transformationController == null) {
      _transformationController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Transform(
      transform: _transformationController!.value,
      child: KeyedSubtree(
        key: _childKey,
        child: widget.child,
      ),
    );

    if (!widget.constrained) {
      child = ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 0.0,
          minHeight: 0.0,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: child,
        ),
      );
    }


    return Listener(
      key: _parentKey,
      onPointerSignal: _receivedPointerSignal,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleEnd: _onScaleEnd,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: child,
      ),
    );
  }
}


class TransformationController extends ValueNotifier<Matrix4> {

  TransformationController([Matrix4? value])
      : super(value ?? Matrix4.identity());


  Offset toScene(Offset viewportPoint) {

    final inverseMatrix = Matrix4.inverted(value);
    final untransformed = inverseMatrix.transform3(Vector3(
      viewportPoint.dx,
      viewportPoint.dy,
      0,
    ));
    return Offset(untransformed.x, untransformed.y);
  }
}


enum _GestureType {
  pan,
  scale,
  rotate,
}


double _getFinalTime(double velocity, double drag) {
  const effectivelyMotionless = 10.0;
  return math.log(effectivelyMotionless / velocity) / math.log(drag / 100);
}

/// Return the translation from the given Matrix4 as an Offset.
Offset _getMatrixTranslation(Matrix4 matrix) {
  final nextTranslation = matrix.getTranslation();
  return Offset(nextTranslation.x, nextTranslation.y);
}

Quad _transformViewport(Matrix4 matrix, Rect viewport) {
  final inverseMatrix = matrix.clone()..invert();
  return Quad.points(
    inverseMatrix.transform3(Vector3(
      viewport.topLeft.dx,
      viewport.topLeft.dy,
      0.0,
    )),
    inverseMatrix.transform3(Vector3(
      viewport.topRight.dx,
      viewport.topRight.dy,
      0.0,
    )),
    inverseMatrix.transform3(Vector3(
      viewport.bottomRight.dx,
      viewport.bottomRight.dy,
      0.0,
    )),
    inverseMatrix.transform3(Vector3(
      viewport.bottomLeft.dx,
      viewport.bottomLeft.dy,
      0.0,
    )),
  );
}


Quad _getAxisAlignedBoundingBoxWithRotation(Rect rect, double rotation) {
  final rotationMatrix = Matrix4.identity()
    ..translate(rect.size.width / 2, rect.size.height / 2)
    ..rotateZ(rotation)
    ..translate(-rect.size.width / 2, -rect.size.height / 2);
  final boundariesRotated = Quad.points(
    rotationMatrix.transform3(Vector3(rect.left, rect.top, 0.0)),
    rotationMatrix.transform3(Vector3(rect.right, rect.top, 0.0)),
    rotationMatrix.transform3(Vector3(rect.right, rect.bottom, 0.0)),
    rotationMatrix.transform3(Vector3(rect.left, rect.bottom, 0.0)),
  );
  return ImagePainterTransformer.getAxisAlignedBoundingBox(boundariesRotated);
}


Offset _exceedsBy(Quad boundary, Quad viewport) {
  final viewportPoints = <Vector3>[
    viewport.point0,
    viewport.point1,
    viewport.point2,
    viewport.point3,
  ];
  var largestExcess = Offset.zero;
  for (final point in viewportPoints) {
    final pointInside =
        ImagePainterTransformer.getNearestPointInside(point, boundary)!;
    final excess = Offset(
      pointInside.x - point.x,
      pointInside.y - point.y,
    );
    if (excess.dx.abs() > largestExcess.dx.abs()) {
      largestExcess = Offset(excess.dx, largestExcess.dy);
    }
    if (excess.dy.abs() > largestExcess.dy.abs()) {
      largestExcess = Offset(largestExcess.dx, excess.dy);
    }
  }

  return _round(largestExcess);
}


Offset _round(Offset offset) {
  return Offset(
    double.parse(offset.dx.toStringAsFixed(9)),
    double.parse(offset.dy.toStringAsFixed(9)),
  );
}


Offset _alignAxis(Offset offset, Axis? axis) {
  switch (axis) {
    case Axis.horizontal:
      return Offset(offset.dx, 0.0);
    case Axis.vertical:
    default:
      return Offset(0.0, offset.dy);
  }
}


Axis? _getPanAxis(Offset? point1, Offset point2) {
  if (point1 == point2) {
    return null;
  }
  final x = point2.dx - point1!.dx;
  final y = point2.dy - point1.dy;
  return x.abs() > y.abs() ? Axis.horizontal : Axis.vertical;
}

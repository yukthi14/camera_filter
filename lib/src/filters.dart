import 'dart:async';
import 'dart:math' as math;
import 'package:camera_filter/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:glass/glass.dart';
import 'package:sizer/sizer.dart';
import '../ripple_effect.dart';

@immutable
class FilterSelector extends StatefulWidget  {
  const FilterSelector({
    Key? key,
    required this.filters,
    required this.onFilterChanged,
    required this.onTap,
    this.onVideoFilter = false,
    this.padding = const EdgeInsets.symmetric(vertical: 24.0),
  }) : super(key: key);

  ///List of filters Color
  final List<Color> filters;

  /// function will call when a user changes the filter
  final void Function(Color selectedColor) onFilterChanged;

  final EdgeInsets padding;

  /// when you tap on filter this on tap will call
  final GestureTapCallback? onTap;

  /// filter for camera or video condition
  final bool? onVideoFilter;

  @override
  _FilterSelectorState createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> with TickerProviderStateMixin
{
  late AnimationController firstRippleController;
  late AnimationController secondRippleController;
  late AnimationController thirdRippleController;
  late AnimationController centerCircleController;
  late Animation<double> firstRippleRadiusAnimation;
  late Animation<double> firstRippleOpacityAnimation;
  late Animation<double> firstRippleWidthAnimation;
  late Animation<double> secondRippleRadiusAnimation;
  late Animation<double> secondRippleOpacityAnimation;
  late Animation<double> secondRippleWidthAnimation;
  late Animation<double> thirdRippleRadiusAnimation;
  late Animation<double> thirdRippleOpacityAnimation;
  late Animation<double> thirdRippleWidthAnimation;
  late Animation<double> centerCircleRadiusAnimation;


  /// filter per screen is by default five
  static const _filtersPerScreen = 5;

  /// screen responsiveness with filters
  static const _viewportFractionPerItem = 1.0 / _filtersPerScreen;

  ///initializer of page controller
  late final PageController _controller;

  ///page number
  late int _page;

  /// filter count form filter list
  int get filterCount => widget.filters.length;

  Color itemColor(int index) => widget.filters[index % filterCount];

  @override
  void initState() {
    super.initState();
    _page = 0;
    _controller = PageController(
      initialPage: _page,
      viewportFraction: _viewportFractionPerItem,
    );
    _controller.addListener(_onPageChanged);
    firstRippleController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    );

    firstRippleRadiusAnimation = Tween<double>(begin: 0, end: 70).animate(
      CurvedAnimation(
        parent: firstRippleController,
        curve: Curves.ease,
      ),
    )
      ..addListener(() {
        setState(() {

        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          firstRippleController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          firstRippleController.forward();
        }
      });

    firstRippleOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: firstRippleController,
        curve: Curves.ease,
      ),
    )..addListener(
          () {
        setState(() {});
      },
    );

    firstRippleWidthAnimation = Tween<double>(begin: 5, end: 0).animate(
      CurvedAnimation(
        parent: firstRippleController,
        curve: Curves.ease,
      ),
    )..addListener(
          () {
        setState(() {});
      },
    );

    secondRippleController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    );

    secondRippleRadiusAnimation = Tween<double>(begin: 0, end: 70).animate(
      CurvedAnimation(
        parent: secondRippleController,
        curve: Curves.ease,
      ),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          secondRippleController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          secondRippleController.forward();
        }
      });

    secondRippleOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: secondRippleController,
        curve: Curves.ease,
      ),
    )..addListener(
          () {
        setState(() {});
      },
    );

    secondRippleWidthAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: secondRippleController,
        curve: Curves.ease,
      ),
    )..addListener(
          () {
        setState(() {});
      },
    );

    thirdRippleController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    );

    thirdRippleRadiusAnimation = Tween<double>(begin: 0, end: 70).animate(
      CurvedAnimation(
        parent: thirdRippleController,
        curve: Curves.ease,
      ),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          thirdRippleController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          thirdRippleController.forward();
        }
      });

    thirdRippleOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: thirdRippleController,
        curve: Curves.ease,
      ),
    )..addListener(
          () {
        setState(() {});
      },
    );

    thirdRippleWidthAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: thirdRippleController,
        curve: Curves.ease,
      ),
    )..addListener(
          () {
        setState(() {});
      },
    );

    centerCircleController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    centerCircleRadiusAnimation = Tween<double>(begin: 2, end: 10).animate(
      CurvedAnimation(
        parent: centerCircleController,
        curve: Curves.fastOutSlowIn,
      ),
    )
      ..addListener(
            () {
          setState(() {});
        },
      )
      ..addStatusListener(
            (status) {
          if (status == AnimationStatus.completed) {
            centerCircleController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            centerCircleController.forward();
          }
        },
      );

    firstRippleController.forward();
    Timer(
      const Duration(milliseconds: 765),
          () => secondRippleController.forward(),
    );

    Timer(
      const Duration(milliseconds: 1050),
          () => thirdRippleController.forward(),
    );

    centerCircleController.forward();
  }

  /// call when filter changes
  void _onPageChanged() {
    final page = (_controller.page ?? 0).round();
    if (page != _page) {
      _page = page;
      widget.onFilterChanged(widget.filters[page]);
    }
  }

  ///call when tap on filters
  void _onFilterTapped(int index) {
    setState(() {
      rippleEffect=false;
    });
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.bounceInOut,
    );


  }

  @override
  void dispose() {
    _controller.dispose();
    firstRippleController.dispose();
    secondRippleController.dispose();
    thirdRippleController.dispose();
    centerCircleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      controller: _controller,
      axisDirection: AxisDirection.right,
      physics: const PageScrollPhysics(),
      viewportBuilder: (context, viewportOffset) {
        return LayoutBuilder(

          builder: (context, constraints) {
            final itemSize = constraints.maxWidth * _viewportFractionPerItem;
            viewportOffset
              ..applyViewportDimension(constraints.maxWidth)
              ..applyContentDimensions(0.0, itemSize * (filterCount - 1));

            return Stack(

              alignment: Alignment.bottomCenter,
              children: [
                _buildShadowGradient(itemSize),
                _buildCarousel(
                  onVideoFilter: widget.onVideoFilter!,
                  viewportOffset: viewportOffset,
                  itemSize: 70,
                ),
                widget.onVideoFilter == true
                    ? Container()
                    : _buildSelectionRing(itemSize - 9),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildShadowGradient(double itemSize) {
    return SizedBox(
      height: itemSize * 1 + widget.padding.vertical,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
            ],
          ),
        ),
        child: SizedBox.expand(),
      ),
     ).asGlass(
      tintColor: Colors.transparent,
        clipBorderRadius: BorderRadius.circular(100.0)
    );
  }

  ///carousel slider of filters
  Widget _buildCarousel({
    required ViewportOffset viewportOffset,
    required double itemSize,
    required bool onVideoFilter,
  }) {
    return Container(
      height: itemSize,
      margin: widget.padding,
      child: Flow(
        delegate: CarouselFlowDelegate(
          viewportOffset: viewportOffset,
          filtersPerScreen: _filtersPerScreen,
        ),
        children: [
          for (int i = 0; i < filterCount; i++)
            FilterItem(
              onVideoFilter: onVideoFilter,
              onFilterSelected: () => _onFilterTapped(i),
              color: itemColor(i), index: i,
            ),
        ],
      ),
    );
  }

  /// filters ui
  Widget _buildSelectionRing(double itemSize) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: IgnorePointer(
        child: Padding(
          padding:  EdgeInsets.only(bottom: 2.8.h, right: 2.w,),
          child: Stack(
            children: [
              SizedBox(
                width: itemSize,
                height: itemSize,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(width: 4.0, color: Colors.white),
                    ),
                  ),
                ),
              ),

          Padding(
            padding: const EdgeInsets.all(35.0),
            child:rippleEffect? CustomPaint(
              painter: MyPainter(
                firstRippleRadiusAnimation.value,
                firstRippleOpacityAnimation.value,
                firstRippleWidthAnimation.value,
                secondRippleRadiusAnimation.value,
                secondRippleOpacityAnimation.value,
                secondRippleWidthAnimation.value,
                thirdRippleRadiusAnimation.value,
                thirdRippleOpacityAnimation.value,
                thirdRippleWidthAnimation.value,
                centerCircleRadiusAnimation.value,
              ),
            ):SizedBox()
          ),
        ]
          ),
      )),
      );
  }
}


class CarouselFlowDelegate extends FlowDelegate {
  CarouselFlowDelegate({
    required this.viewportOffset,
    required this.filtersPerScreen,
  }) : super(repaint: viewportOffset);

  final ViewportOffset viewportOffset;
  final int filtersPerScreen;

  @override
  void paintChildren(FlowPaintingContext context) {
    final count = context.childCount;

    /// All available painting width
    final size = context.size.width;

    final itemExtent = size / filtersPerScreen;


    final active = viewportOffset.pixels / itemExtent;

    final int min = math.max(0, active.floor() - 3);


    final int max = math.min(count - 1, active.ceil() + 3);

    /// Generate transforms for the visible items and sort by distance.
    for (var index = min; index <= max; index++) {
      final itemXFromCenter = itemExtent * index - viewportOffset.pixels;
      final percentFromCenter = 1.0 - (itemXFromCenter / (size / 2)).abs();
      final itemScale = 0.5 + (percentFromCenter * 0.5);
      final opacity = 0.25 + (percentFromCenter * 0.75);

      final itemTransform = Matrix4.identity()
        ..translate((size - itemExtent) / 2)..translate(
            itemXFromCenter)..translate(itemExtent / 2, itemExtent / 2)
        ..multiply(Matrix4.diagonal3Values(itemScale, itemScale, 2.0))
        ..translate(-itemExtent / 2, -itemExtent / 2);

      context.paintChild(
        index,
        transform: itemTransform,
        opacity: opacity,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CarouselFlowDelegate oldDelegate) {
    return oldDelegate.viewportOffset != viewportOffset;
  }
}

@immutable
class FilterItem extends StatelessWidget {
  const FilterItem({
    Key? key,
    required this.color,
    required this.onVideoFilter,
    required this.index,
    this.onFilterSelected,
  }) : super(key: key);

  final Color color;
  final bool onVideoFilter;
  final int index;
  final VoidCallback? onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFilterSelected,
      child: onVideoFilter == true
          ? Container()
          : AspectRatio(
        aspectRatio: 1.0,
        child: ClipOval(
          child: Image.network(
            "https://i.pinimg.com/236x/7d/41/74/7d4174a43fc88e7f2dc4a70fc4200f58.jpg",
            color: color.withOpacity(0.9),
            fit: BoxFit.fill,
            colorBlendMode: BlendMode.hardLight,
          ),
        ),
      ),
    );
  }
}

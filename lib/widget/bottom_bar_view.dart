import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mikan_flutter/ext/screen.dart';

class BarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String iconPath;
  final String selectedIconPath;
  final VoidCallback onClick;
  bool isSelected;
  int _index = 0;
  double _size;
  AnimationController _animationController;

  BarItem({
    this.icon,
    this.selectedIcon,
    this.iconPath,
    this.selectedIconPath,
    this.onClick,
    this.isSelected = false,
  });
}

class BottomBarView extends StatefulWidget {
  const BottomBarView({
    Key key,
    this.items,
    this.onItemClick,
    this.height = 64,
    this.iconSize = 30,
  })  : assert(height > iconSize),
        super(key: key);

  final Function(int index) onItemClick;
  final List<BarItem> items;
  final double height;
  final double iconSize;

  @override
  _BottomBarViewState createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView>
    with TickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height + Sz.navBarHeight,
      padding: EdgeInsets.only(bottom: Sz.navBarHeight),
      child: AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Transform(
            transform: Matrix4.translationValues(0.0, 0.0, 0.0),
            child: PhysicalShape(
              color: Colors.white,
              elevation: 16.0,
              clipper: TabClipper(
                radius: Tween<double>(begin: 0.0, end: 1.0)
                        .animate(
                          CurvedAnimation(
                            parent: animationController,
                            curve: Curves.fastOutSlowIn,
                          ),
                        )
                        .value *
                    widget.height,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildBarItemView(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildBarItemView() {
    List<Widget> bars = List(widget.items.length);
    for (int i = 0; i < widget.items.length; i++) {
      widget.items[i]._index = i;
      widget.items[i]._size = widget.iconSize;
      bars[i] = _BottomBarItemView(
        barItem: widget.items[i],
        removeAllSelect: () {
          setRemoveAllSelection(widget.items[i]);
          widget.onItemClick(i);
        },
      );
    }
    return bars;
  }

  void setRemoveAllSelection(BarItem item) {
    if (!mounted) return;
    setState(() {
      widget.items.forEach((BarItem tab) {
        tab.isSelected = false;
        if (item._index == tab._index) {
          tab.isSelected = true;
        }
      });
    });
  }
}

class _BottomBarItemView extends StatefulWidget {
  const _BottomBarItemView({Key key, this.barItem, this.removeAllSelect})
      : super(key: key);

  final BarItem barItem;
  final Function removeAllSelect;

  @override
  _BottomBarItemViewState createState() => _BottomBarItemViewState();
}

class _BottomBarItemViewState extends State<_BottomBarItemView>
    with TickerProviderStateMixin {
  List<Widget> _points;

  @override
  void initState() {
    widget.barItem._animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (!mounted) return;
          widget.removeAllSelect();
          widget.barItem._animationController.reverse();
        }
      });
    super.initState();
  }

  void setAnimation() {
    widget.barItem?._animationController?.forward();
  }

  Widget _toBarIcon(final BarItem barItem) {
    if (barItem.isSelected) {
      return barItem.selectedIcon == null
          ? Image.asset(
        barItem.selectedIconPath,
        width: barItem._size + 4,
        height: barItem._size + 4,
      )
          : Icon(
        barItem.selectedIcon,
        size: barItem._size + 4,
        color: Theme
            .of(context)
            .accentColor,
      );
    }
    return barItem.icon == null
        ? Image.asset(
      barItem.iconPath,
      width: barItem._size,
      height: barItem._size,
    )
        : Icon(
      barItem.icon,
      size: barItem._size,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_points == null) {
      _points = _buildPoints(context);
    }
    return Container(
      child: AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () {
              if (!widget.barItem.isSelected) {
                setAnimation();
              }
              if (widget.barItem.onClick != null) {
                widget.barItem.onClick();
              }
            },
            child: IgnorePointer(
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: <Widget>[
                  ScaleTransition(
                    alignment: Alignment.center,
                    scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                        CurvedAnimation(
                            parent: widget.barItem._animationController,
                            curve: Interval(0.1, 1.0,
                                curve: Curves.fastOutSlowIn))),
                    child: _toBarIcon(widget.barItem),
                  ),
                  ..._points,
                ],
              ),
            ),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 8),
    );
  }

  Positioned _buildPoint(BuildContext context, final double size,
      final double angle, final Color color, final List<double> interval) {
    final radius = (64 - 16) / 2;
    final x = radius * math.cos(angle);
    final y = radius * math.sin(angle);
    double left;
    double right;
    double top;
    double bottom;
    if (0 <= angle && 90 > angle) {
      right = radius - x.abs();
      top = radius - y.abs();
    } else if (90 <= angle && 180 > angle) {
      left = radius - x.abs();
      top = radius - y.abs();
    } else if (180 <= angle && 270 > angle) {
      left = radius - x.abs();
      bottom = radius - y.abs();
    } else {
      right = radius - x.abs();
      bottom = radius - y.abs();
    }
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ScaleTransition(
        alignment: Alignment.center,
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.barItem._animationController,
            curve: Interval(interval[0], interval[1],
                curve: Curves.fastOutSlowIn))),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPoints(BuildContext context) {
    final random = math.Random();
    final int count = random.nextInt(2) + 3;
    List<Widget> points = List(count);
    final double offset = 360 / count;
    final out = (offset / 4).floor();
    final always = offset - out;
    final Color color = Theme.of(context).accentColor;
    double angle;
    for (int i = 0; i < count; i++) {
      angle = offset * i + random.nextInt(out) + always;
      points[i] = _buildPoint(
        context,
        random.nextDouble() * 5 + 3,
        angle,
        color.withOpacity((random.nextDouble() + 0.1).clamp(0.1, 1.0)),
        [
          (random.nextDouble()).clamp(0, 0.7),
          (random.nextDouble()).clamp(0.8, 1)
        ],
      );
    }
    return points;
  }
}

class TabClipper extends CustomClipper<Path> {
  TabClipper({this.radius = 38.0});

  final double radius;

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, 0);
    path.arcTo(Rect.fromLTWH(0, 0, radius, radius), degreeToRadians(180),
        degreeToRadians(90), false);
    path.arcTo(Rect.fromLTWH(size.width - radius, 0, radius, radius),
        degreeToRadians(270), degreeToRadians(90), false);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(TabClipper oldClipper) => true;

  double degreeToRadians(double degree) {
    return (math.pi / 180) * degree;
  }
}

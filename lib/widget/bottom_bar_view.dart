import 'dart:math' as math;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/screen.dart';

class BarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String iconPath;
  final String selectedIconPath;
  final VoidCallback onClick;
  bool isSelected;
  int _index = 0;
  double _size;

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
    this.iconSize = 28,
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
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height + Sz.navBarHeight,
      padding: EdgeInsets.only(bottom: Sz.navBarHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16.0),
          topLeft: Radius.circular(16.0),
        ),
        color: Theme.of(context).backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _buildBarItemView(),
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
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (!mounted) return;
          widget.removeAllSelect();
          _animationController.reverse();
        }
      });
    super.initState();
  }

  void setAnimation() {
    _animationController?.forward();
  }

  Widget _toBarIcon(final BarItem barItem) {
    if (barItem.isSelected) {
      return barItem.selectedIcon == null
          ? ExtendedImage.asset(
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
        ? ExtendedImage.asset(
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
                        parent: _animationController,
                        curve: Interval(
                          0.1,
                          1.0,
                          curve: Curves.fastOutSlowIn,
                        ),
                      ),
                    ),
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

  Positioned _buildPoint(BuildContext context,
      final double size,
      final double angle,
      final Color color,
      final List<double> interval,) {
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
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              interval[0],
              interval[1],
              curve: Curves.bounceInOut,
            ),
          ),
        ),
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

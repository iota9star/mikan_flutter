import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Indicator {
  static Widget _build(final Widget spin, final String msg, final double height,
      final double top, final double bottom) {
    return Container(
      padding: EdgeInsets.only(top: top, bottom: bottom),
      height: height + top + bottom,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            spin,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                msg,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  static Widget idle(
    final BuildContext context,
    final Color color, {
    final double height = 72,
    final double top = 0,
    final double bottom = 0,
  }) {
    return _build(SpinKitPumpingHeart(size: 18, color: color), "使点劲", height,
        top, bottom);
  }

  static Widget can(
    final BuildContext context,
    final Color color, {
    final double height = 72,
    final double top = 0,
    final double bottom = 0,
  }) {
    return _build(
        SpinKitSquareCircle(size: 18, color: color), "松手", height, top, bottom);
  }

  static Widget ing(
    final BuildContext context,
    final Color color, {
    final double height = 72,
    final double top = 0,
    final double bottom = 0,
  }) {
    return _build(
      SpinKitPumpingHeart(
        size: 18,
        itemBuilder: (_, __) {
          return ExtendedImage.asset(
            "assets/mikan.png",
            width: 32.0,
            height: 32.0,
          );
        },
        duration: Duration(milliseconds: 800),
      ),
      "加载中，请稍候...",
      height,
      top,
      bottom,
    );
  }

  static Widget completed(
    final BuildContext context,
    final Color color, {
    final double height = 72,
    final double top = 0,
    final double bottom = 0,
  }) {
    return _build(
        SpinKitDualRing(size: 18, color: color), "加载完成", height, top, bottom);
  }

  static Widget failed(
    final BuildContext context,
    final Color color, {
    final double height = 72,
    final double top = 0,
    final double bottom = 0,
  }) {
    return _build(SpinKitPumpingHeart(size: 18, color: color), "点击重试", height,
        top, bottom);
  }

  static Widget noMore(
    final BuildContext context,
    final Color color, {
    final double height = 72,
    final double top = 0,
    final double bottom = 0,
  }) {
    return _build(
        SpinKitDoubleBounce(size: 18, color: color), "没啦", height, top, bottom);
  }

  static Widget header(
    final BuildContext context,
    final Color color, {
    final double height = 72,
    final double top = 0,
  }) {
    return CustomHeader(
      height: height + top,
      builder: (context, RefreshStatus? mode) {
        switch (mode) {
          case RefreshStatus.idle:
            return idle(context, color, height: height, top: top);
          case RefreshStatus.canRefresh:
            return can(context, color, height: height, top: top);
          case RefreshStatus.refreshing:
            return ing(context, color, height: height, top: top);
          case RefreshStatus.completed:
            return completed(context, color, height: height, top: top);
          case RefreshStatus.failed:
            return failed(context, color, height: height, top: top);
          case RefreshStatus.canTwoLevel:
          case RefreshStatus.twoLevelOpening:
          case RefreshStatus.twoLeveling:
          case RefreshStatus.twoLevelClosing:
          default:
          return sizedBox;
        }
      },
    );
  }

  static Widget footer(
    final BuildContext context,
    final Color color, {
    final double height = 72,
    final double bottom = 0,
  }) {
    return CustomFooter(
      height: height + bottom,
      builder: (BuildContext context, LoadStatus? mode) {
        switch (mode) {
          case LoadStatus.idle:
            return idle(context, color, height: height, bottom: bottom);
          case LoadStatus.canLoading:
            return can(context, color, height: height, bottom: bottom);
          case LoadStatus.loading:
            return ing(context, color, height: height, bottom: bottom);
          case LoadStatus.noMore:
            return noMore(context, color, height: height, bottom: bottom);
          case LoadStatus.failed:
            return failed(context, color, height: height, bottom: bottom);
          default:
            return sizedBox;
        }
      },
    );
  }
}

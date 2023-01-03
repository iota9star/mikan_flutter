import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    required this.onTap,
    required this.icon,
    required this.tooltip,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: RippleTap(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: 16.0),
        ),
      ),
    );
  }
}

class TorrentButton extends StatelessWidget {
  const TorrentButton({Key? key, required this.payload}) : super(key: key);
  final String payload;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      onTap: () {
        payload.launchAppAndCopy();
      },
      icon: Icons.send_and_archive_rounded,
      tooltip: '复制并尝试打开种子链接',
    );
  }
}

class MagnetButton extends StatelessWidget {
  const MagnetButton({Key? key, required this.payload}) : super(key: key);
  final String payload;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      onTap: () {
        payload.launchAppAndCopy();
      },
      icon: Icons.downloading_rounded,
      tooltip: '复制并尝试打开磁力链接',
    );
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({Key? key, required this.payload}) : super(key: key);
  final String payload;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      onTap: () {
        payload.share();
      },
      icon: Icons.share_rounded,
      tooltip: '分享',
    );
  }
}

class CircleBackButton extends StatelessWidget {
  const CircleBackButton({Key? key, this.color}) : super(key: key);

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return RippleTap(
      onTap: () {
        Navigator.pop(context);
      },
      color: color ?? Theme.of(context).backgroundColor,
      shape: const CircleBorder(),
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(
          Icons.west_rounded,
          size: 20.0,
        ),
      ),
    );
  }
}

class SmallCircleButton extends StatelessWidget {
  const SmallCircleButton({
    Key? key,
    required this.onTap,
    required this.icon,
    this.color,
  }) : super(key: key);
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return RippleTap(
      onTap: onTap,
      color: color ?? Theme.of(context).backgroundColor,
      shape: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 16.0),
      ),
    );
  }
}

class RightArrowButton extends StatelessWidget {
  const RightArrowButton({Key? key, required this.onTap, this.color})
      : super(key: key);
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SmallCircleButton(
      onTap: onTap,
      icon: Icons.east_rounded,
      color: color,
    );
  }
}

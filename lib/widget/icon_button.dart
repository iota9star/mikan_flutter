import 'package:flutter/material.dart';

import '../internal/extension.dart';
import 'ripple_tap.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
      ),
    );
  }
}

class TorrentButton extends StatelessWidget {
  const TorrentButton({super.key, required this.payload});

  final String payload;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      onTap: payload.launchAppAndCopy,
      icon: Icons.send_and_archive_rounded,
      tooltip: '复制并尝试打开种子链接',
    );
  }
}

class MagnetButton extends StatelessWidget {
  const MagnetButton({super.key, required this.payload});

  final String payload;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      onTap: payload.launchAppAndCopy,
      icon: Icons.downloading_rounded,
      tooltip: '复制并尝试打开磁力链接',
    );
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, required this.payload});

  final String payload;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      onTap: payload.share,
      icon: Icons.share_rounded,
      tooltip: '分享',
    );
  }
}

class TMSMenuButton extends StatelessWidget {
  const TMSMenuButton({
    super.key,
    required this.torrent,
    required this.magnet,
    required this.share,
  });

  final String torrent;
  final String magnet;
  final String share;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: const Offset(-90.0, -8.0),
      menuChildren: [
        MenuItemButton(
          onPressed: torrent.launchAppAndCopy,
          leadingIcon: const Icon(Icons.send_and_archive_rounded),
          child: const Text('下载种子'),
        ),
        MenuItemButton(
          onPressed: magnet.launchAppAndCopy,
          leadingIcon: const Icon(Icons.downloading_rounded),
          child: const Text('打开磁力'),
        ),
        MenuItemButton(
          onPressed: share.share,
          leadingIcon: const Icon(Icons.share_rounded),
          child: const Text('分享信息'),
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          icon: const Icon(Icons.more_horiz_rounded),
        );
      },
    );
  }
}

class BackIconButton extends StatelessWidget {
  const BackIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.maybePop(context),
      icon: const Icon(Icons.west_rounded),
    );
  }
}

class SmallCircleButton extends StatelessWidget {
  const SmallCircleButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return RippleTap(
      onTap: onTap,
      color: color ?? Theme.of(context).colorScheme.surface,
      shape: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 16.0),
      ),
    );
  }
}

class RightArrowButton extends StatelessWidget {
  const RightArrowButton({super.key, required this.onTap, this.color});

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

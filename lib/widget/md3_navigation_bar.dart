import 'package:flutter/material.dart';

class M3NavigationItem {
  const M3NavigationItem({required this.icon, required this.label, this.selectedIcon, this.initial = false});

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool initial;
}

class M3NavigationBar extends StatefulWidget {
  const M3NavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.height = 72,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : assert(items.length >= 2 && items.length <= 5);

  final List<M3NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final double height;
  final Duration animationDuration;

  @override
  State<M3NavigationBar> createState() => _M3NavigationBarState();
}

class _M3NavigationBarState extends State<M3NavigationBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: widget.height,
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        color: colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.items.length, (index) {
          return Expanded(
            child: _NavItem(
              item: widget.items[index],
              isSelected: widget.selectedIndex == index,
              onTap: () => widget.onDestinationSelected(index),
              animationDuration: widget.animationDuration,
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.item, required this.isSelected, required this.onTap, required this.animationDuration});

  final M3NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final iconColor = isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;
    final labelColor = isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      splashColor: colorScheme.primary.withValues(alpha: 0.12),
      highlightColor: colorScheme.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: animationDuration,
              padding: EdgeInsets.all(isSelected ? 8 : 0),
              decoration: ShapeDecoration(
                color: isSelected ? colorScheme.primaryContainer : null,
                shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(16.0)),
              ),
              child: Icon(
                isSelected && item.selectedIcon != null ? item.selectedIcon! : item.icon,
                color: iconColor,
                size: 24,
              ),
            ),
            AnimatedContainer(
              duration: animationDuration,
              height: isSelected ? 0 : 16,
              child: Text(
                item.label,
                style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

/// A drop-in replacement for [IndexedStack] that lazily builds tab children
/// when first visited, while keeping visited tabs alive.
///
/// Unlike [IndexedStack], children that have never been shown are not built,
/// reducing initial memory usage.
class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({super.key, required this.selectedIndex, required this.children});

  /// The index of the currently visible child.
  final int selectedIndex;

  /// The list of child widgets. Only the one at [selectedIndex] and previously
  /// visited indices are kept in the tree.
  final List<Widget> children;

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  /// Tracks which indices have been visited and should be kept alive.
  final Set<int> _visitedIndices = {};

  @override
  void initState() {
    super.initState();
    _visitedIndices.add(widget.selectedIndex);
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      setState(() {
        _visitedIndices.add(widget.selectedIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List.generate(widget.children.length, (index) {
        final isVisible = index == widget.selectedIndex;
        final isVisited = _visitedIndices.contains(index);
        // Only build children that are currently visible or have been visited before
        if (!isVisible && !isVisited) {
          return const SizedBox.shrink();
        }
        return _PositionedChild(key: ValueKey(index), visible: isVisible, child: widget.children[index]);
      }),
    );
  }
}

/// A wrapper that positions its child to fill the stack and optionally hides it
/// when not the active tab (but keeps it in the tree for state preservation).
class _PositionedChild extends StatelessWidget {
  const _PositionedChild({super.key, required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Offstage(offstage: !visible, child: child),
    );
  }
}

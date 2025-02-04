import 'package:flutter/material.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/harpy_widgets/harpy_widgets.dart';

/// A tab for a [HarpyTabBar].
class HarpyTab extends StatefulWidget {
  const HarpyTab({
    required this.icon,
    this.text,
    this.cardColor,
  });

  final Widget icon;
  final Widget? text;

  final Color? cardColor;

  /// The height of a tab.
  static const double height = tabPadding * 2 + tabIconSize;

  static const double tabPadding = 16;
  static const double tabIconSize = 20;

  @override
  _HarpyTabState createState() => _HarpyTabState();
}

class _HarpyTabState extends State<HarpyTab>
    with SingleTickerProviderStateMixin<HarpyTab> {
  /// Controls how much the tab's associated content is in view.
  ///
  /// 1: Tab content is fully in view and tab should appear selected.
  /// 0: Tab content is not visible.
  late AnimationController _animationController;

  late Animation<Color?> _colorAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this)
      ..addListener(() => setState(() {}));

    _opacityAnimation = Tween<double>(
      begin: 1,
      end: .5,
    ).animate(_animationController);

    _textOpacityAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, .5),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (HarpyTabScope.of(context) != null) {
      _animationController.value = HarpyTabScope.of(context)!.animationValue;
    }

    final theme = Theme.of(context);

    _colorAnimation = ColorTween(
      begin: theme.colorScheme.primary,
      end: theme.textTheme.subtitle1!.color,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    super.dispose();

    _animationController.dispose();
  }

  Widget _buildText() {
    return Opacity(
      opacity: _textOpacityAnimation.value,
      child: Align(
        widthFactor: 1 - _animationController.value,
        alignment: Alignment.centerRight,
        child: Row(
          children: [
            defaultSmallHorizontalSpacer,
            widget.text!,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconTheme = IconTheme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) => Opacity(
        opacity: _opacityAnimation.value,
        child: Card(
          color: widget.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(HarpyTab.tabPadding),
            child: IconTheme(
              data: iconTheme.copyWith(
                color: _colorAnimation.value,
                size: HarpyTab.tabIconSize,
              ),
              child: DefaultTextStyle(
                style: theme.textTheme.subtitle1!.copyWith(
                  color: _colorAnimation.value,
                ),
                child: SizedBox(
                  height: HarpyTab.tabIconSize,
                  child: Row(
                    children: [
                      widget.icon,
                      if (widget.text != null) _buildText(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Exposes values for the [HarpyTab].
class HarpyTabScope extends InheritedWidget {
  const HarpyTabScope({
    required this.index,
    required this.animationValue,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  final int index;

  /// A value between 0 and 1 that corresponds to how much the tab content
  /// for [index] is in view.
  final double animationValue;

  static HarpyTabScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HarpyTabScope>();
  }

  @override
  bool updateShouldNotify(HarpyTabScope oldWidget) {
    return oldWidget.index != index ||
        oldWidget.animationValue != animationValue;
  }
}

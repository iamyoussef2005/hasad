import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FrostedGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final Border? border;
  final VoidCallback? onTap;

  const FrostedGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.blur = 10,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius.clamp(0, 12)),
        side:
            border?.top ??
            BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }
    return content;
  }
}

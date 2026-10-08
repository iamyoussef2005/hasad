import 'package:flutter/material.dart';

/// A custom high-performance shimmer container that requires zero external packages.
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.1, 0.45, 0.8],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

/// A convenient rounded rectangle skeleton block
class ShimmerBlock extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBlock({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Ready-made skeleton for Grid produce items
class ProduceGridSkeleton extends StatelessWidget {
  const ProduceGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBlock(width: 48, height: 48, borderRadius: 14),
                    ShimmerBlock(width: 50, height: 22, borderRadius: 12),
                  ],
                ),
                SizedBox(height: 12),
                ShimmerBlock(width: 90, height: 16),
                SizedBox(height: 6),
                ShimmerBlock(width: 50, height: 12),
                Spacer(),
                ShimmerBlock(height: 24, borderRadius: 8),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBlock(width: 60, height: 20),
                    ShimmerBlock(width: 32, height: 32, borderRadius: 10),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Ready-made skeleton for Dashboard screen
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            // Greeting card skeleton
            const ShimmerBlock(height: 72, borderRadius: 20),
            const SizedBox(height: 16),
            // Quick actions skeleton
            const Row(
              children: [
                Expanded(child: ShimmerBlock(height: 48, borderRadius: 14)),
                SizedBox(width: 8),
                Expanded(child: ShimmerBlock(height: 48, borderRadius: 14)),
                SizedBox(width: 8),
                ShimmerBlock(width: 48, height: 48, borderRadius: 14),
              ],
            ),
            const SizedBox(height: 16),
            // Alert banner skeleton
            const ShimmerBlock(height: 80, borderRadius: 18),
            const SizedBox(height: 16),
            // 4 KPI cards skeleton
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.25,
              children: List.generate(
                4,
                (_) => const ShimmerBlock(height: 120, borderRadius: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

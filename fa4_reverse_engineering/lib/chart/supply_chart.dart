import 'package:flutter/material.dart';

import 'dart:math' as math;

class SupplyBarItem {
  final double value;
  final Color categoryColor;

  const SupplyBarItem({required this.value, required this.categoryColor});
}

class SupplyChart extends StatelessWidget {
  final bool isLoading;
  final List<SupplyBarItem> items;
  final double height;

  const SupplyChart({
    super.key,
    required this.isLoading,
    this.items = const [],
    this.height = 210.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF925047) : const Color(0xFFFAD5CF),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: isLoading
            ? const _LoadingPlaceholderPainterWidget()
            : _BarChartContent(
                items: items,
                barColor: isDark
                    ? const Color(0xFFE8BDB7)
                    : const Color(0xFF795852),
              ),
      ),
    );
  }
}

class _LoadingPlaceholderPainterWidget extends StatefulWidget {
  const _LoadingPlaceholderPainterWidget();

  @override
  State<_LoadingPlaceholderPainterWidget> createState() {
    return _LoadingPlaceholderPainterWidgetState();
  }
}

class _LoadingPlaceholderPainterWidgetState
    extends State<_LoadingPlaceholderPainterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SupplyLoadingCurvePainter(
            progress: _controller.value,
            color: isDark ? const Color(0xFFE8BDB7) : const Color(0xFF795852),
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SupplyLoadingCurvePainter extends CustomPainter {
  final double progress;
  final Color color;

  const _SupplyLoadingCurvePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      size.width * 0.04,
      size.height * 0.12,
      size.width * 0.88,
      size.height * 0.62,
    );
    final double startAngle = progress * 2 * math.pi;
    canvas.drawArc(rect, 0.0, 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant _SupplyLoadingCurvePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _BarChartContent extends StatelessWidget {
  final List<SupplyBarItem> items;
  final Color barColor;

  const _BarChartContent({required this.items, required this.barColor});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final double maxValue = items.fold(
      0.0,
      (max, item) => math.max(max, item.value),
    );
    final double effectiveMax = maxValue > 0 ? maxValue : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: items.map((item) {
          final double fraction = (item.value / effectiveMax).clamp(0.0, 1.0);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: item.value <= 0 ? 0.0 : fraction,
                        widthFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    height: 16.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: item.categoryColor,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

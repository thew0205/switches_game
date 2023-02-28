import 'dart:math';

import 'package:flutter/material.dart';

import 'core/colors.dart';
import 'core/functions.dart';

class SwitchesLoadingIndicator extends StatefulWidget {
  const SwitchesLoadingIndicator({
    Key? key,
    this.onColor = switchesColor,
    this.offColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.size = 50.0,
  }) : super(key: key);
  final Color onColor;
  final Color offColor;
  final Color backgroundColor;
  final double size;
  @override
  State<SwitchesLoadingIndicator> createState() =>
      _SwitchesLoadingIndicatorState();
}

class _SwitchesLoadingIndicatorState extends State<SwitchesLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  _SwitchesLoadingIndicatorState();
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: ColoredBox(
        color: widget.backgroundColor,
        child: CustomPaint(
          foregroundPainter: SwitchesLoadingIndicatorPainter(
            animation: _controller,
            backgroundColor: widget.backgroundColor,
            offColor: widget.offColor,
            onColor: widget.onColor,
          ),
        ),
      ),
    );
  }
}

class SwitchesLoadingIndicatorPainter extends CustomPainter {
  SwitchesLoadingIndicatorPainter({
    required Color onColor,
    required Color offColor,
    required this.backgroundColor,
    required Animation<double> animation,
  })  : animationValue = animation,
        painter0 = Paint()..color = offColor,
        painter1 = Paint()..color = onColor,
        super(repaint: animation);

  final Color backgroundColor;
  final Paint painter0;
  final Paint painter1;
  final Animation<double> animationValue;
  double get value => animationValue.value;
  bool get notReverse => animationValue.status != AnimationStatus.reverse;

  bool hasNotChanged = true;
  bool change = false;
  bool get canChange {
    return notReverse && hasNotChanged;
  }

  void shouldChange() {
    if (canChange) {
      change = !change;
      hasNotChanged = false;
    } else if (!notReverse) {
      hasNotChanged = true;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final smallest =
        size.height < size.width ? size.height / 2 : size.width / 2;
    final smallRadius = 4.0 * smallest / 15.0;
    final bigRadius = 2 * smallRadius;
   
    shouldChange();
    final angle = notReverse ? value : 1 - value;
    canvas.drawCircle(
        Offset(centerX + bigRadius * cos(numToAngle(angle)),
            centerY + bigRadius * sin(numToAngle(angle))),
        mapBetween(value, 0, 1, 1, smallRadius),
        change ? painter0 : painter1);
    canvas.drawCircle(
        Offset(centerX + bigRadius * cos(numToAngle(angle + 0.25)),
            centerY + bigRadius * sin(numToAngle(angle + 0.25))),
        mapBetween(value, 0, 1, 1, smallRadius),
        change ? painter1 : painter0);
    canvas.drawCircle(
        Offset(centerX + bigRadius * cos(numToAngle(angle + 0.5)),
            centerY + bigRadius * sin(numToAngle(angle + 0.5))),
        mapBetween(value, 0, 1, 1, smallRadius),
        change ? painter0 : painter1);
    canvas.drawCircle(
        Offset(centerX + bigRadius * cos(numToAngle(angle + 0.75)),
            centerY + bigRadius * sin(numToAngle(angle + 0.75))),
        mapBetween(value, 0, 1, 0.5, smallRadius),
        change ? painter1 : painter0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

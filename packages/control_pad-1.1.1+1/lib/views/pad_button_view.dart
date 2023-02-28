import 'dart:collection';
import 'dart:math' as _math;

import 'package:control_pad/models/gestures.dart';
import 'package:control_pad/models/pad_button_item.dart';
import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';

import 'circle_view.dart';

typedef PadButtonPressedCallback = void Function(
    int buttonIndex, Gestures gesture);

class PadButtonsView extends StatelessWidget {
  /// [size] optional parameter, space for background circle of all pad buttons. It will be
  /// recalculated for pad buttons size.
  ///
  /// Default value is calculated according to screen size.
  final double? size;

  ///should it be in a square form
  final bool isSquare;

  /// List of pad buttons, default contains 4 buttons
  final List<PadButtonItem> buttons;

  /// [padButtonPressedCallback] contains information which button(index) was
  /// used by user and what gesture was done on it.
  final PadButtonPressedCallback? padButtonPressedCallback;

  /// [buttonsStateMap] contains current colors of each button.
  final Map<int, Color> buttonsStateMap = HashMap<int, Color>();

  /// [buttonsPadding] optional parameter to ad paddings for buttons.
  final double buttonsPadding;

  /// [backgroundPadButtonsColor] optional parameter, when set it shows circle.
  final Color backgroundPadButtonsColor;

  final void Function(int)? onHold;

  final void Function(int)? onCancel;

  PadButtonsView({
    this.size,
    this.buttons = const [
      PadButtonItem(index: 0, buttonText: 'A'),
      PadButtonItem(index: 1, buttonText: 'B', pressedColor: Colors.red),
      PadButtonItem(index: 2, buttonText: 'C', pressedColor: Colors.green),
      PadButtonItem(index: 3, buttonText: 'D', pressedColor: Colors.yellow),
    ],
    this.padButtonPressedCallback,
    this.buttonsPadding = 0,
    this.backgroundPadButtonsColor = Colors.transparent,
    this.isSquare = false,
    this.onHold,
    this.onCancel,
  }) : assert(buttons.isNotEmpty) {
    buttons.forEach(
        (button) => buttonsStateMap[button.index] = button.backgroundColor);
  }

  @override
  Widget build(BuildContext context) {
    var actualSize = size != null
        ? size!
        : _math.min(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height) *
            0.5;
    var innerCircleSize = actualSize / 3;

    return Center(
        child: Stack(children: createButtons(innerCircleSize, actualSize)));
  }

  List<Widget> createButtons(double innerCircleSize, double actualSize) {
    var list = <Widget>[];
    list.add(CircleView.padBackgroundCircle(
        actualSize,
        backgroundPadButtonsColor,
        backgroundPadButtonsColor != Colors.transparent
            ? Colors.black45
            : Colors.transparent,
        backgroundPadButtonsColor != Colors.transparent
            ? Colors.black12
            : Colors.transparent));

    for (var i = 0; i < buttons.length; i++) {
      var padButton = buttons[i];
      list.add(createPositionedButtons(
        padButton,
        actualSize,
        i,
        innerCircleSize,
      ));
    }
    return list;
  }

  Positioned createPositionedButtons(PadButtonItem padButton, double actualSize,
      int index, double innerCircleSize) {
    return Positioned(
      top: isSquare
          ? _calculateSquarePositionYOfButton(
              index, innerCircleSize, actualSize)
          : _calculatePositionYOfButton(index, innerCircleSize, actualSize),
      left: isSquare
          ? _calculateSquarePositionXOfButton(
              index, innerCircleSize, actualSize)
          : _calculatePositionXOfButton(index, innerCircleSize, actualSize),
      child: StatefulBuilder(builder: (context, setState) {
        return HoldDetector(
          onCancel: () {
            _onCancel(padButton);
            setState(() =>
                buttonsStateMap[padButton.index] = padButton.backgroundColor);
          },
          onHold: () {
            _onHold(padButton);
            setState(() =>
                buttonsStateMap[padButton.index] = padButton.pressedColor);
          },
          holdTimeout: padButton.holdTimeout,
          enableHapticFeedback: true,
          child: GestureDetector(
            onTap: () {
              _processGesture(padButton, Gestures.TAP);
            },
            onTapUp: (details) {
              _processGesture(padButton, Gestures.TAPUP);
              Future.delayed(const Duration(milliseconds: 50), () {
                setState(() => buttonsStateMap[padButton.index] =
                    padButton.backgroundColor);
              });
            },
            onTapDown: (details) {
              _processGesture(padButton, Gestures.TAPDOWN);

              setState(() =>
                  buttonsStateMap[padButton.index] = padButton.pressedColor);
            },
            onTapCancel: () {
              _processGesture(padButton, Gestures.TAPCANCEL);

              setState(() =>
                  buttonsStateMap[padButton.index] = padButton.backgroundColor);
            },
            onLongPress: () {
              _processGesture(padButton, Gestures.LONGPRESS);
            },
            onLongPressStart: (details) {
              _processGesture(padButton, Gestures.LONGPRESSSTART);

              setState(() =>
                  buttonsStateMap[padButton.index] = padButton.pressedColor);
            },
            onLongPressUp: () {
              _processGesture(padButton, Gestures.LONGPRESSUP);

              setState(() =>
                  buttonsStateMap[padButton.index] = padButton.backgroundColor);
            },
            onDoubleTap: () {
              _processGesture(padButton, Gestures.DOUBLETAP);
              // Future.delayed(const Duration(milliseconds: 50), () {
              //   setState(() => buttonsStateMap[padButton.index] =
              //       padButton.backgroundColor);
              // });
            },
            onDoubleTapCancel: () {
              _processGesture(padButton, Gestures.DOUBLETAPCANCEL);
            },
            onDoubleTapDown: (details) {
              _processGesture(padButton, Gestures.DOUBLETAPDOWN);

              // setState(() =>
              //     buttonsStateMap[padButton.index] = padButton.pressedColor);
            },
            child: Padding(
              padding: EdgeInsets.all(buttonsPadding),
              child: CircleView.padButtonCircle(
                  innerCircleSize,
                  buttonsStateMap[padButton.index],
                  padButton.buttonImage,
                  padButton.buttonIcon,
                  padButton.buttonText),
            ),
          ),
        );
      }),
    );
  }

  void _processGesture(PadButtonItem button, Gestures gesture) {
    if (padButtonPressedCallback != null &&
        button.supportedGestures.contains(gesture)) {
      padButtonPressedCallback!(button.index, gesture);
    }
  }

  void _onHold(PadButtonItem button) {
    if (onHold != null) {
      onHold!(button.index);
    }
  }

  void _onCancel(PadButtonItem button) {
    if (onCancel != null) {
      onCancel!(button.index);
    }
  }

  // bool _canCallOnDirectionChanged(DateTime? callbackTimestamp) {
  //   if (interval != null && callbackTimestamp != null) {
  //     var intervalMilliseconds = interval!.inMilliseconds;
  //     var timestampMilliseconds = callbackTimestamp.millisecondsSinceEpoch;
  //     var currentTimeMilliseconds = DateTime.now().millisecondsSinceEpoch;

  //     if (currentTimeMilliseconds - timestampMilliseconds <=
  //         intervalMilliseconds) {
  //       return false;
  //     }
  //   }

  //   return true;
  // }

  double _calculatePositionXOfButton(
      int index, double innerCircleSize, double actualSize) {
    var degrees = 360 / buttons.length * index;
    var lastAngleRadians = (degrees) * (_math.pi / 180.0);

    var rBig = actualSize / 2;
    var rSmall = (innerCircleSize + 2 * buttonsPadding) / 2;

    return (rBig - rSmall) + (rBig - rSmall) * _math.cos(lastAngleRadians);
  }

  double _calculatePositionYOfButton(
      int index, double innerCircleSize, double actualSize) {
    var degrees = 360 / buttons.length * index;
    var lastAngleRadians = (degrees) * (_math.pi / 180.0);
    var rBig = actualSize / 2;
    var rSmall = (innerCircleSize + 2 * buttonsPadding) / 2;

    return (rBig - rSmall) + (rBig - rSmall) * _math.sin(lastAngleRadians);
  }

  double _calculateSquarePositionXOfButton(
      int index, double innerCircleSize, double actualSize) {
    var degrees = (360 / 4 * index) - 45;
    var lastAngleRadians = (degrees) * (_math.pi / 180.0);

    var rBig = actualSize / 2;
    var rSmall = (innerCircleSize + 2 * buttonsPadding) / 2;

    return (rBig - rSmall) + (rBig - rSmall) * _math.cos(lastAngleRadians);
  }

  double _calculateSquarePositionYOfButton(
      int index, double innerCircleSize, double actualSize) {
    var degrees = (360 / 4 * index) - 45;
    var lastAngleRadians = (degrees) * (_math.pi / 180.0);
    var rBig = actualSize / 2;
    var rSmall = (innerCircleSize + 2 * buttonsPadding) / 2;

    return (rBig - rSmall) + (rBig - rSmall) * _math.sin(lastAngleRadians);
  }
}

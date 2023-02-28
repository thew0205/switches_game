import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';

double mapBetween(double value, double minFrom, double maxFrom,
    [double minTo = 0, double maxTo = 1]) {
  if (value < minFrom) {
    while (value < minFrom) {
      value += maxFrom;
    }
  }
  if (value > maxFrom) {
    while (value > maxFrom) {
      value -= maxFrom;
    }
  }

  return (((value - minFrom) / (maxFrom - minFrom)) * (maxTo - minTo)) + minTo;
}

double numToAngle(num value, [num min = 0, num max = 1, bool maxIs360 = true]) {
  if (value < min) {
    while (value < min) {
      value += max;
    }
  }
  if (value > max) {
    while (value > max) {
      value -= max;
    }
  }

  return (((value - min) / (max - min)) * 2 * pi) + min;
}

Offset sizeToOffset(Size size, [double? x, double? y]) {
  if (x == null || y == null) {
    x = 1.0;
    y = 1.0;
  }
  return Offset(size.width * x / 4.0, size.height * y / 4.0);
}

TextStyle getTextStyle(
    {Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle}) {
  return GoogleFonts.sourceSansPro(
    color: color,
    backgroundColor: backgroundColor,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
  );
}

String bluetoothStateToString(BluetoothState state) {
  if (BluetoothState.STATE_ON == state) {
    return "On";
  } else if (BluetoothState.STATE_TURNING_ON == state) {
    return "Turning on";
  }
  if (BluetoothState.STATE_TURNING_OFF == state) {
    return "Turning off";
  } else {
    return "Off";
  }
}

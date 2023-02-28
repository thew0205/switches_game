import 'dart:async';

import 'package:control_pad/control_pad.dart';
import 'package:control_pad/models/pad_button_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';


import 'connection_provider.dart';
import 'core/colors.dart';
import 'core/constant_widget.dart';
import 'core/functions.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({Key? key}) : super(key: key);

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  // ignore: unused_field
  StreamSubscription<MapEntry<String, bool>>? _isConnectedStreamSubscription;
  String? serverName;
  @override
  void initState() {
    super.initState();
    serverName = context.read<CarConnectionProvider>().server.name;
    _isConnectedStreamSubscription =
        context.read<CarConnectionProvider>().IsConnectedStream?.listen((pair) {
      const duration = Duration(milliseconds: 2000);
      const animationDuration = Duration(milliseconds: 300);
      if (pair.key == ConnectionProvider.cannotConnectKey) {
        if (pair.value) {
          showTopSnackBar(
            reverseAnimationDuration: animationDuration,
            animationDuration: animationDuration,
            context,
            displayDuration: duration,
            const CustomSnackBar.error(
              message:
                  "An error occurred while trying to connect. Please try again.",
            ),
          );
          Future.delayed(duration + animationDuration * 3)
              .then((value) => Navigator.of(context).pop());
        }
      } else if (pair.key == ConnectionProvider.isConnectedKey) {
        if (pair.value) {
          showTopSnackBar(
            context,
            CustomSnackBar.success(
              backgroundColor: switchesColor,
              message: "You are connected with $serverName.",
            ),
          );
        } else {
          showTopSnackBar(
            reverseAnimationDuration: animationDuration,
            animationDuration: animationDuration,
            context,
            displayDuration: duration,
            CustomSnackBar.error(
                message:
                    "Something went wrong while connecting with with $serverName. Please try again"),
          );
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  int i = 0;
  @override
  Widget build(BuildContext context) {
    return Selector<CarConnectionProvider, bool>(
      selector: (context, connectionProvider) => connectionProvider.isConnected,
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(title: Consumer<CarConnectionProvider>(
            builder: (context, connectionProvider, child) {
              return connectionProvider.isConnecting
                  ? Text('Connecting pad to ${serverName ?? "Unknown"} ...')
                  : connectionProvider.isConnected
                      ? Text('Connected with ${serverName ?? "Unknown"}')
                      : Text(
                          'Connection error with ${serverName ?? "Unknown"}');
            },
          )),
          body: Builder(builder: (context) {
            return IgnorePointer(
              ignoring: !value,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DisplayWidget(),
                  const Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: ControllerWidget(),
                      ),
                    ),
                  ),
                  if (!value) switchesIndicator,
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class ControllerWidget extends StatelessWidget {
  const ControllerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (Orientation.landscape == orientation) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              JoystickView(
                iconsColor: Colors.white,
                innerCircleColor: Colors.white,
                backgroundImage: ColoredBox(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      "assets/images/switches.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                backgroundColor: switchesColor,
                interval: const Duration(milliseconds: 25),
                onDirectionChanged: (degrees, distance) {
                  if (0 == degrees && 0 == distance) {
                    context.read<CarConnectionProvider>().sendData('0');
                  } else {
                    final tempDegree = degreeToDirection(degrees);
                    tempDegree == null
                        ? null
                        : context
                            .read<CarConnectionProvider>()
                            .sendData(tempDegree);
                  }
                },
              ),
              PadButtonsView(
                isSquare: true,
                padButtonPressedCallback: (buttonIndex, gesture) {
                  if (2 == buttonIndex) {
                    context.read<CarConnectionProvider>().sendData('7');
                  } else if (3 == buttonIndex) {
                    context.read<CarConnectionProvider>().sendData('8');
                  }
                },
                onHold: (buttonIndex) {
                  final temp = onHold(buttonIndex);
                  print(temp);
                  temp == null
                      ? null
                      : context.read<CarConnectionProvider>().sendData(temp);
                },
                buttons: const [
                  PadButtonItem(
                      supportedGestures: [],
                      holdTimeout: Duration(milliseconds: 50),
                      index: 0,
                      buttonIcon:
                          Icon(Icons.arrow_upward_rounded, color: Colors.green),
                      pressedColor: Colors.green),
                  PadButtonItem(
                      supportedGestures: [],
                      holdTimeout: Duration(milliseconds: 50),
                      index: 1,
                      buttonIcon: Icon(
                        Icons.arrow_downward,
                        color: Colors.blue,
                      ),
                      pressedColor: Colors.blue),
                  PadButtonItem(
                      index: 2,
                      buttonIcon: Icon(Icons.stop_circle, color: Colors.red),
                      pressedColor: Colors.red),
                  PadButtonItem(
                      holdTimeout: Duration(milliseconds: 200),
                      index: 3,
                      buttonIcon: Icon(Icons.play_arrow, color: Colors.purple),
                      pressedColor: Colors.purple),
                ],
              ),
            ],
          );
        } else {
          return FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                JoystickView(
                  iconsColor: Colors.white,
                  innerCircleColor: Colors.white,
                  backgroundImage: ColoredBox(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        "assets/images/switches.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  backgroundColor: switchesColor,
                  interval: const Duration(milliseconds: 25),
                  onDirectionChanged: (degrees, distance) {
                    if (0 == degrees && 0 == distance) {
                      context.read<CarConnectionProvider>().sendData('0');
                    } else {
                      final tempDegree = degreeToDirection(degrees);
                      tempDegree == null
                          ? null
                          : context
                              .read<CarConnectionProvider>()
                              .sendData(tempDegree);
                    }
                  },
                ),
                PadButtonsView(
                  isSquare: true,
                  padButtonPressedCallback: (buttonIndex, gesture) {
                    if (2 == buttonIndex) {
                      context.read<CarConnectionProvider>().sendData('7');
                    } else if (3 == buttonIndex) {
                      context.read<CarConnectionProvider>().sendData('8');
                    }
                  },
                  onHold: (buttonIndex) {
                    final temp = onHold(buttonIndex);
                    print(temp);
                    temp == null
                        ? null
                        : context.read<CarConnectionProvider>().sendData(temp);
                  },
                  buttons: const [
                    PadButtonItem(
                        supportedGestures: [],
                        holdTimeout: Duration(milliseconds: 50),
                        index: 0,
                        buttonIcon: Icon(Icons.arrow_upward_rounded,
                            color: Colors.green),
                        pressedColor: Colors.green),
                    PadButtonItem(
                        supportedGestures: [],
                        holdTimeout: Duration(milliseconds: 50),
                        index: 1,
                        buttonIcon: Icon(
                          Icons.arrow_downward,
                          color: Colors.blue,
                        ),
                        pressedColor: Colors.blue),
                    PadButtonItem(
                        index: 2,
                        buttonIcon: Icon(Icons.stop_circle, color: Colors.red),
                        pressedColor: Colors.red),
                    PadButtonItem(
                        holdTimeout: Duration(milliseconds: 200),
                        index: 3,
                        buttonIcon:
                            Icon(Icons.play_arrow, color: Colors.purple),
                        pressedColor: Colors.purple),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // int? onpadButtonPressedCallbackTap(int button, Gestures gesture) {
  //   int? ret;
  //   switch (button) {
  //     case 0:
  //       ret = 5;
  //       break;
  //     case 1:
  //       ret = 6;
  //       break;
  //     case 2:
  //       ret = 0;
  //       break;
  //     default:
  //   }
  //   return ret;
  // }

  String? onHold(int button) {
    String? ret;
    switch (button) {
      case 0:
        ret = '5';
        break;
      case 1:
        ret = '6';
        break;
      case 3:
        ret = '8';
        break;
      default:
    }
    return ret;
  }

  // int _joyStickCallback(double degree, double distance) {
  //   int ret;
  //   if (degree == 0 && distance == 0) {
  //     ret = 0;
  //   } else {
  //     ret = degreeToDirection(degree);
  //   }
  //   return ret;
  // }

  String? degreeToDirection(double degree) {
    if ((degree >= 315 && degree < 360) || (degree >= 0 && degree < 45)) {
      return '1'; //up
    }
    if (degree >= 45 && degree < 135) {
      return '2'; //right
    }
    if (degree >= 135 && degree < 225) {
      return '3'; //down
    }
    if (degree >= 225 && degree < 315) {
      return '4'; //left
    }
    return null;
  }
}

class DisplayWidget extends StatelessWidget {
  const DisplayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectionProvider = context.watch<CarConnectionProvider>();
    final style = getTextStyle(color: switchesColor, fontSize: 16);
    const sizedBox = SizedBox(height: 9);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
              "Obstacle at : ${connectionProvider.obstacleDistance.toStringAsFixed(2)}cm",
              style: style),
          sizedBox,
          Text(
            "Speed: ${connectionProvider.speed.toStringAsFixed(2)}m/s",
            style: style,
          ),
          sizedBox,
          Text(
            "Distance covered: ${connectionProvider.distanceCovered.toStringAsFixed(2)}m",
            style: style,
          ),
          sizedBox,
          Text(
            "Acceleration: ${connectionProvider.acceleration.toStringAsFixed(2)}m/s**2",
            style: style,
          )
        ],
      ),
    );
  }
}

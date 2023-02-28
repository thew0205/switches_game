import 'dart:async';

import 'package:control_pad/control_pad.dart';
import 'package:control_pad/models/gestures.dart';
import 'package:control_pad/models/pad_button_item.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:provider/provider.dart';
import 'package:switches_game/core/functions.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'connection_provider.dart';
import 'core/colors.dart';
import 'core/constant_widget.dart';
import 'core/control_data.dart';

class SnakeControlPage extends StatefulWidget {
  const SnakeControlPage({Key? key}) : super(key: key);

  @override
  State<SnakeControlPage> createState() => _SnakeControlPageState();
}

class _SnakeControlPageState extends State<SnakeControlPage> {
  StreamSubscription<MapEntry<String, bool>>? _isConnectedStreamSubscription;
  String? serverName;
  bool isFirstTime = true;
  bool joystickControl = true;
  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 2000);
    const animationDuration = Duration(milliseconds: 300);

    serverName = context.read<SnakeConnectionProvider>().server.name;
    _isConnectedStreamSubscription = context
        .read<SnakeConnectionProvider>()
        .IsConnectedStream
        ?.listen((pair) {
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

  @override
  Widget build(BuildContext context) {
    return Selector<SnakeConnectionProvider, Tuple3<bool, bool, bool>>(
      selector: (context, connectionProvider) => Tuple3(
          connectionProvider.isConnected,
          connectionProvider.isGameOver,
          connectionProvider.isPlaying),
      builder: (context, value, child) {
        Widget? popup;
        if (!value.item1) {
          popup = switchesIndicator;
        } else if (value.item2) {
          popup = Positioned.fill(
            child: ColoredBox(
              color: Colors.black38,
              child: Center(
                child: AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Start a new game."),
                      IconButton(
                          iconSize: 20,
                          onPressed: () {
                            context
                                .read<SnakeConnectionProvider>()
                                .sendData('r');
                          },
                          icon: const Icon(Icons.play_arrow, color: switchesColor)),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (!value.item3) {
          popup = Positioned.fill(
            child: ColoredBox(
              color: Colors.black38,
              child: Center(
                child: AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Game paused."),
                      IconButton(
                          iconSize: 20,
                          onPressed: () {
                            context
                                .read<SnakeConnectionProvider>()
                                .sendData('p');
                          },
                          icon: const Icon(Icons.play_arrow, color: switchesColor)),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          popup = null;
        }
        return Scaffold(
          floatingActionButton: Builder(builder: (context) {
            final connectionProvider = context.watch<SnakeConnectionProvider>();
            return FloatingActionButton(
                backgroundColor: Colors.grey,
                child: Icon(
                  connectionProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: switchesColor,
                ),
                onPressed: () {
                  context
                      .read<SnakeConnectionProvider>()
                      .sendData(SnakeControlData.play);
                });
          }),
          appBar: AppBar(
              title: Consumer<SnakeConnectionProvider>(
                builder: (context, connectionProvider, child) {
                  return connectionProvider.isConnecting
                      ? Text('Connecting pad to ${serverName ?? "Unknown"} ...')
                      : connectionProvider.isConnected
                          ? Text('Connected with ${serverName ?? "Unknown"}')
                          : Text(
                              'Connection error with ${serverName ?? "Unknown"}');
                },
              ),
              actions: [
                IconButton(
                    icon: const Icon(
                      Icons.restart_alt,
                    ),
                    onPressed: () {
                      setState(() {
                        joystickControl = !joystickControl;
                      });
                    }),
                IconButton(
                    icon: const Icon(
                      Icons.stop,
                    ),
                    onPressed: () {
                      isFirstTime = false;
                      context
                          .read<SnakeConnectionProvider>()
                          .sendData(SnakeControlData.restart);
                    }),
                PopupMenuButton<String>(
                  initialValue: SnakeControlData.easy,
                  onSelected: (String value) {
                    context.read<SnakeConnectionProvider>().sendData(value);
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<String>(
                        value: SnakeControlData.easy,
                        child: Text("Easy"),
                      ),
                      const PopupMenuItem<String>(
                        value: SnakeControlData.medium,
                        child: Text("Medium"),
                      ),
                      const PopupMenuItem<String>(
                        value: SnakeControlData.hard,
                        child: Text("Hard"),
                      ),
                      const PopupMenuItem<String>(
                        value: SnakeControlData.superstar,
                        child: Text("Superstar"),
                      ),
                      const PopupMenuItem<String>(
                        value: SnakeControlData.ultimate,
                        child: Text("Ultimate"),
                      ),
                    ];
                  },
                )
              ]),
          body: Builder(builder: (context) {
            return IgnorePointer(
              ignoring: !value.item1,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const DisplayWidget(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: ControllerWidget(
                              joystickControl: joystickControl),
                        ),
                      ),
                    ],
                  ),
                  if (popup != null) popup
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
  const ControllerWidget({Key? key, required this.joystickControl})
      : super(key: key);
  final bool joystickControl;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: (joystickControl)
          ? JoystickView(
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
                if (distance < 0.1) return;
                final tempDegree = degreeToDirection(degrees);
                tempDegree == null
                    ? null
                    : context
                        .read<SnakeConnectionProvider>()
                        .sendData(tempDegree);
              },
            )
          : PadButtonsView(
              isSquare: false,
              padButtonPressedCallback: (buttonIndex, gesture) {
                String? temp =
                    onPadButtonPressedCallbackTap(buttonIndex, gesture);
                print(temp);
                temp == null
                    ? null
                    : context.read<SnakeConnectionProvider>().sendData(temp);
              },
              onHold: (buttonIndex) {
                String? temp = onHold(buttonIndex);
                print(temp);
                temp == null
                    ? null
                    : context.read<SnakeConnectionProvider>().sendData(temp);
              },
              buttons: const [
                PadButtonItem(
                    supportedGestures: [
                      Gestures.TAP,
                      Gestures.TAPUP,
                      Gestures.TAPDOWN,
                      Gestures.TAPCANCEL
                    ],
                    holdTimeout: Duration(milliseconds: 50),
                    index: 0,
                    buttonIcon:
                        Icon(Icons.chevron_right_rounded, color: Colors.purple),
                    pressedColor: Colors.purple),
                PadButtonItem(
                    supportedGestures: [
                      Gestures.TAP,
                      Gestures.TAPUP,
                      Gestures.TAPDOWN,
                      Gestures.TAPCANCEL
                    ],
                    holdTimeout: Duration(milliseconds: 50),
                    index: 1,
                    buttonIcon:
                        Icon(Icons.expand_more_rounded, color: Colors.red),
                    pressedColor: Colors.red),
                PadButtonItem(
                    supportedGestures: [
                      Gestures.TAP,
                      Gestures.TAPUP,
                      Gestures.TAPDOWN,
                      Gestures.TAPCANCEL
                    ],
                    holdTimeout: Duration(milliseconds: 50),
                    index: 2,
                    buttonIcon: Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.blue,
                    ),
                    pressedColor: Colors.blue),
                PadButtonItem(
                    supportedGestures: [
                      Gestures.TAP,
                      Gestures.TAPUP,
                      Gestures.TAPDOWN,
                      Gestures.TAPCANCEL
                    ],
                    holdTimeout: Duration(milliseconds: 50),
                    index: 3,
                    buttonIcon:
                        Icon(Icons.expand_less_rounded, color: Colors.green),
                    pressedColor: Colors.green),
              ],
            ),
    );
  }

  String? onPadButtonPressedCallbackTap(int button, Gestures gesture) {
    String? ret;
    switch (button) {
      case 0:
        ret = SnakeControlData.right;
        break;
      case 1:
        ret = SnakeControlData.down;
        break;
      case 2:
        ret = SnakeControlData.left;
        break;
      case 3:
        ret = SnakeControlData.up;
        break;
      default:
    }
    return ret;
  }

  String? onHold(int button) {
    String? ret ;
    switch (button) {
      case 0:
        ret = SnakeControlData.right;
        break;
      case 1:
        ret = SnakeControlData.down;
        break;
      case 2:
        ret = SnakeControlData.left;
        break;
      case 3:
        ret = SnakeControlData.up;
        break;
      default:
    }
    return ret;
  }

  String? degreeToDirection(double degree) {
    if ((degree >= 315 && degree <= 360) || (degree >= 0 && degree < 45)) {
      return SnakeControlData.up; //up
    }
    if (degree >= 45 && degree < 135) {
      return SnakeControlData.right; //right
    }
    if (degree >= 135 && degree < 235) {
      return SnakeControlData.down; //down
    }
    if (degree >= 235 && degree < 315) {
      return SnakeControlData.left; //left
    }
    return null;
  }
}

class DisplayWidget extends StatelessWidget {
  const DisplayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectionProvider = context.watch<SnakeConnectionProvider>();
    final style = getTextStyle(color: switchesColor, fontSize: 24);
    const sizedBox = SizedBox(height: 9);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          sizedBox,
          sizedBox,
          Text("Score : ${connectionProvider.score.toString()}", style: style),
          sizedBox,
          Text(
            "Level: ${speedToString(connectionProvider.speed)}",
            style: style,
          ),
        ],
      ),
    );
  }
}

String speedToString(int speed) {
  switch (speed) {
    case 0:
      return "Easy";
    case 1:
      return "Medium";
    case 2:
      return "Hard";
    case 3:
      return "Superstar";
    case 4:
      return "Ultimate";
    default:
      return "Medium";
  }
}


//  Expanded(
//           flex: 1,
//           child: PadButtonsView(
//             isSquare: false,
//             padButtonPressedCallback: (buttonIndex, gesture) {
//               String? temp =
//                   onPadButtonPressedCallbackTap(buttonIndex, gesture);
//               print(temp);
//               temp == null
//                   ? null
//                   : context
//                       .read<SnakeConnectionProvider>()
//                       .sendData(buttonIndex.toString());
//             },
//             buttons: const [
//               PadButtonItem(
//                   holdTimeout: Duration(milliseconds: 50),
//                   index: 1,
//                   buttonIcon: Icon(Icons.arrow_upward, color: Colors.green),
//                   pressedColor: Colors.green),
//               PadButtonItem(
//                   holdTimeout: Duration(milliseconds: 50),
//                   index: 0,
//                   buttonIcon: Icon(Icons.arrow_downward, color: Colors.red),
//                   pressedColor: Colors.red),
//             ],
//           ),
//         ),
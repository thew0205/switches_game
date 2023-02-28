import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'core/colors.dart';

PreferredSize getAppBar() {
  return const PreferredSize(
    preferredSize: Size.fromHeight(250),
    child: SwitchesAppBar(),
  );
}

class SwitchesAppBar extends StatefulWidget {
  const SwitchesAppBar({
    Key? key,
  }) : super(key: key);

  @override
  State<SwitchesAppBar> createState() => _SwitchesAppBarState();
}

class _SwitchesAppBarState extends State<SwitchesAppBar> {
  var currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
              icon: const Icon(
                Icons.settings,
                color: switchesColor,
              ),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              }),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: SizedBox(
          height: 250,
          child: SafeArea(
            bottom: false,
            left: true,
            top: true,
            right: true,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: SvgPicture.asset(
                  alignment: Alignment.center,
                  "assets/images/switches_icon.svg",
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:switches_game/core/functions.dart';
import 'package:switches_game/switches_custom_loading_indicator.dart';

import 'core/colors.dart';
import 'switches_control.dart';

void main() async {
  runApp(const SwitchesControlApp());
}

class SwitchesControlApp extends StatelessWidget {
  const SwitchesControlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: switchesColor,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                foregroundColor: switchesColor, textStyle: GoogleFonts.sourceSansPro(
                    fontSize: 18, color: switchesColor))),
        textTheme: GoogleFonts.sourceSansProTextTheme(),
        appBarTheme: const AppBarTheme(color: switchesColor),
        // primaryColor: switchesColor,
        brightness: Brightness.light,
        colorSchemeSeed: switchesColor,
      ),
      home: FutureBuilder<bool?>(
        future: FlutterBluetoothSerial.instance.isAvailable.then((value) async {
          await Future.delayed(const Duration(seconds: 1));
          return value;
        }),
        // .then((value) async {
        //   if (value ?? false) {
        //     if (await FlutterBluetoothSerial.instance.isEnabled ?? false) {
        //       if (await FlutterBluetoothSerial.instance.requestEnable() ??
        //           false) {
        //         return true;
        //       }
        //     }
        //   } else {
        //     return false;
        //   }
        // }),

        builder: (context, snapshot) {
          if (ConnectionState.waiting == snapshot.connectionState) {
            return Scaffold(
              appBar: AppBar(title: const Text("Switches")),
              body: Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          "Trying to check bluetooth availability.",
                          style:
                              getTextStyle(color: switchesColor, fontSize: 20),
                        ),
                      )),
                  const Expanded(
                      flex: 4,
                      child: Center(
                          child: SwitchesLoadingIndicator(size: 200))),
                ],
              ),
            );
          } else {
            if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: const Text("Switches")),
                body: const Center(child: Text("An error ocurred")),
              );
            } else {
              if (snapshot.data ?? false) {
                return const SwitchesControlPage();
              } else {
                return Scaffold(
                  appBar: AppBar(title: const Text("Switches")),
                  body: const Center(
                      child: Text("Bluetooth is not available on this device")),
                );
              }
            }
          }
        },
      ),
    );
  }
}

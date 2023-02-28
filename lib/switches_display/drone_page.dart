import 'package:flutter/material.dart';

import 'dart:async';

import 'package:provider/provider.dart';
import 'package:switches_game/core/functions.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../connection_provider.dart';
import '../core/colors.dart';

class DroneDataPage extends StatefulWidget {
  const DroneDataPage({Key? key}) : super(key: key);

  @override
  State<DroneDataPage> createState() => _DroneDataPageState();
}

class _DroneDataPageState extends State<DroneDataPage> {
  // ignore: unused_field
  StreamSubscription<MapEntry<String, bool>>? _isConnectedStreamSubscription;
  String? serverName;
  bool isFirstTime = true;
  bool joystickControl = true;
  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 2000);
    const animationDuration = Duration(milliseconds: 300);

    serverName = context.read<DroneConnectionProvider>().server.name;
    _isConnectedStreamSubscription = context
        .read<DroneConnectionProvider>()
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

  DataRow toTableRow(DroneSensorInfo data) {
    return DataRow(
      cells: [
        DataCell(Text(data.time.format(context))),
        DataCell(Text("${data.AirHum}")),
        DataCell(Text("${data.AirTemp}")),
        DataCell(Text("${data.SoilPh}")),
        DataCell(Text("${data.SoilHum}")),
        DataCell(Text("${data.GasConc}")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectionProvider = context.watch<DroneConnectionProvider>();
    return Selector<DroneConnectionProvider, bool>(
      selector: (context, connectionProvider) => connectionProvider.isConnected,
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("Harvested Data")),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
                child: Text(
                  "Harvested data for the day: ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 24),
                ),
              ),
              const Divider(color: Colors.grey, height: 3),
              Expanded(
                child: SingleChildScrollView(
                    child: Center(
                  child: FittedBox(
                    child: DataTable(
                      decoration: const BoxDecoration(),
                      headingRowColor: MaterialStateProperty.all(switchesColor),
                      border: TableBorder.all(
                          borderRadius: BorderRadius.circular(4)),
                      dataTextStyle: getTextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                      headingTextStyle: getTextStyle(fontSize: 24),
                      columns: const [
                        DataColumn(label: Text("Time")),
                        DataColumn(label: Text("AirHum"), numeric: true),
                        DataColumn(label: Text("AirTemp"), numeric: true),
                        DataColumn(label: Text("SoilPh"), numeric: true),
                        DataColumn(label: Text("SoilHum"), numeric: true),
                        DataColumn(label: Text("GasConc"), numeric: true),
                      ],
                      rows: connectionProvider.sensorData
                          .map((data) => toTableRow(data))
                          .toList(),
                    ),
                  ),
                )),
              ),
            ],
          ),
        );
      },
    );
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
//                       .read<DroneConnectionProvider>()
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
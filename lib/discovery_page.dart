// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'package:switches_game/core/colors.dart';

import 'bluetooth_device_list_entry.dart';
import 'core/constant_widget.dart';
import 'switches_custom_loading_indicator.dart';

class DiscoveryPage extends StatefulWidget {
  /// If true, discovery starts on page start, otherwise user must press action button.
  final bool start;

  const DiscoveryPage({
    Key? key,
    this.start = true,
  }) : super(key: key);

  @override
   State<DiscoveryPage> createState() => _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;
  bool isConnecting = false;
  _DiscoveryPage();

  @override
  void initState() {
    super.initState();

    isDiscovering = widget.start;
    if (isDiscovering) {
      _startDiscovery();
    }
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0) {
          results[existingIndex] = r;
        } else {
          results.add(r);
        }
      });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  // @TODO . One day there should be `_pairDevice` on long tap on something... ;)

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isConnecting,
      child: Scaffold(
        appBar: AppBar(
          title: isDiscovering
              ? const Text('Discovering devices')
              : const Text('Discovered devices'),
          actions: <Widget>[
            isDiscovering
                ? const FittedBox(child: SwitchesLoadingIndicator())
                : IconButton(
                    icon: const Icon(Icons.replay),
                    onPressed: _restartDiscovery,
                  )
          ],
        ),
        body: Stack(
          children: [
            if (isConnecting) switchesIndicator,
            ListView.builder(
              itemCount: results.length,
              itemBuilder: (BuildContext context, index) {
                BluetoothDiscoveryResult result = results[index];
                final device = result.device;
                final address = device.address;
                return BluetoothDeviceListEntry(
                  device: device,
                  rssi: result.rssi,
                  onLongPress: () {
                    Navigator.of(context).pop(result.device);
                  },
                  onTap: () async {
                    setState(() {
                      isConnecting = true;
                    });
                    try {
                      bool bonded = false;

                      if (device.isBonded) {
                        await FlutterBluetoothSerial.instance
                            .removeDeviceBondWithAddress(address)
                            .then((value) {
                          bonded = value ?? false;
                          if (bonded) {
                            showTopSnackBar(
                              context,
                              CustomSnackBar.success(
                                backgroundColor: switchesColor,
                                message:
                                    "Unbonding successful with ${device.name??"Unknown"}",
                              ),
                            );
                          } else {
                            showTopSnackBar(
                              context,
                              CustomSnackBar.error(
                                message:
                                    "Something went wrong while connecting with ${device.name??"Unknown"}. Please try again",
                              ),
                            );
                          }
                        });
                      } else {
                        await FlutterBluetoothSerial.instance
                            .bondDeviceAtAddress(address)
                            .then((value) {
                          if (value ?? false) {
                            showTopSnackBar(
                              context,
                              CustomSnackBar.success(
                                backgroundColor: switchesColor,
                                message:
                                    "Bonding successful with ${device.name}",
                              ),
                            );
                          } else {
                            showTopSnackBar(
                              context,
                              CustomSnackBar.error(
                                message:
                                    "Something went wrong while connecting with ${device.name??"Unknown"}. Please try again",
                              ),
                            );
                          }
                        });
                      }

                      setState(() {
                        results[results.indexOf(result)] =
                            BluetoothDiscoveryResult(
                                device: BluetoothDevice(
                                  name: device.name ?? '',
                                  address: address,
                                  type: device.type,
                                  bondState: device.isBonded
                                      ? BluetoothBondState.bonded
                                      : BluetoothBondState.none,
                                ),
                                rssi: result.rssi);
                      });
                    } catch (ex) {
                      showTopSnackBar(
                        context,
                        CustomSnackBar.error(message: ex.toString()),
                      );
                    } finally {
                      setState(() {
                        isConnecting = false;
                      });
                      _restartDiscovery();
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


//  showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return FutureBuilder<bool?>(
//                             future: FlutterBluetoothSerial.instance
//                                 .removeDeviceBondWithAddress(address),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return const Center(
//                                     child: SizedBox.square(
//                                         dimension: 100,
//                                         child: SwitchesLoadingIndicator()));
//                               } else {
//                                 if (snapshot.hasData) {
//                                   return AlertDialog(
//                                     title: Text(snapshot.data ?? false
//                                         ? "Unbounded successfully"
//                                         : 'Error occurred while unbounding'),
//                                     content: Text(snapshot.data.toString()),
//                                     actions: <Widget>[
//                                       TextButton(
//                                         child: const Text("Close"),
//                                         onPressed: () {
//                                           Navigator.of(context).pop();
//                                           print(snapshot.error.toString());
//                                           setState(() {});
//                                         },
//                                       ),
//                                     ],
//                                   );
//                                 } else {
//                                   return AlertDialog(
//                                     title: const Text('Error while unbonding'),
//                                     content: Text(snapshot.error.toString()),
//                                     actions: <Widget>[
//                                       TextButton(
//                                         child: const Text("Close"),
//                                         onPressed: () {
//                                           print(snapshot.error.toString());
//                                           Navigator.of(context).pop();
//                                           setState(() {});
//                                         },
//                                       ),
//                                     ],
//                                   );
//                                 }
//                               }
//                             },
//                           );
//                         },
//                       );
                     
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:switches_game/chat_page.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'custom_appbar.dart';
import 'switches_display/screen_page.dart';

import 'connection_provider.dart';
import 'control_page.dart';
import 'core/colors.dart';
import 'core/functions.dart';
import 'discovery_page.dart';
import 'select_bonded_device_page.dart';
import 'snake_control.dart';
import 'switches_display/drone_page.dart';

class SwitchesControlPage extends StatefulWidget {
  const SwitchesControlPage({Key? key}) : super(key: key);

  @override
  State<SwitchesControlPage> createState() => _SwitchesControlPageState();
}

class _SwitchesControlPageState extends State<SwitchesControlPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _name = "...";
  String _address = "...";

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    future() async {
      if (!((await FlutterBluetoothSerial.instance.isEnabled) ?? false)) {
        await FlutterBluetoothSerial.instance.requestEnable();
      }
    }

    future().then((_) {
      showTopSnackBar(
        context,
        const CustomSnackBar.success(
          backgroundColor: switchesColor,
          message: "Your bluetooth is now active.",
        ),
      );
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            activeColor: switchesColor,
            title: const Text('Enable Bluetooth'),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              // Do the request and update with the true value then
              try {
                future() async {
                  // async lambda seems to not working
                  if (value) {
                    await FlutterBluetoothSerial.instance.requestEnable();
                  } else {
                    await FlutterBluetoothSerial.instance.requestDisable();
                  }
                }

                future().then((_) {
                  setState(() {});
                });
              } catch (e) {
                showTopSnackBar(
                  context,
                  const CustomSnackBar.error(
                    backgroundColor: switchesColor,
                    message: "An error occurred. Try again.",
                  ),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Bluetooth name'),
            subtitle: Text(
              _name,
              style:
                  GoogleFonts.sourceSansPro(fontSize: 14, color: switchesColor),
            ),
          ), 
          ListTile(
            title: const Text('Local adapter address')                                                             ,
            subtitle: Text(
              _address,
              style:
                  GoogleFonts.sourceSansPro(fontSize: 14, color: switchesColor),
            ),
          ),
          ListTile(
            title: const Text('Bluetooth status'),
            subtitle: Text(
              bluetoothStateToString(_bluetoothState),
              style:
                  GoogleFonts.sourceSansPro(fontSize: 14, color: switchesColor),
            ),
            trailing: ElevatedButton(
              child: const Text('Settings'),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
            ),
          ),
          const Divider(),
          const ListTile(title: Text('Devices discovery and connection')),
          ListTile(
            title: TextButton(
              child: const Text('Explore discovered devices'),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const DiscoveryPage();
                    },
                  ),
                );
              },
            ),
          ),
          ListTile(
            title: TextButton(
              child: const Text(
                'Connect to display',
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                          checkAvailability: true);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  _getScreenControlPage(selectedDevice);
                }
              },
            ),
          ),
          ListTile(
            title: TextButton(
              child: const Text(
                'Connect to Gateway',
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                          checkAvailability: true);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  _getDroneDataPage(selectedDevice);
                }
              },
            ),
          ),
          ListTile(
            title: TextButton(
              child: const Text('Connect to paired device to control car',),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                          checkAvailability: true);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  _getCarControlPage(selectedDevice);
                }
              },
            ),
          ),
          ListTile(
            title: TextButton(
              child: const Text(
                'Connect to paired device to control display',
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                          checkAvailability: true);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  _getScreenControlPage(selectedDevice);
                }
              },
            ),
          ),
          ListTile(
            title: TextButton(
              child: const Text(
                'Connect to paired device to play snake',
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                          checkAvailability: true);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  _getSnakeGameControlPage(selectedDevice);
                }
              },
            ),
          ),
          ListTile(
            title: TextButton(
              child: const Text('Connect to chat page',),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                          checkAvailability: true);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  _getChatPage(selectedDevice);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _getCarControlPage(BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider<CarConnectionProvider>(
            create: (_) => CarConnectionProvider(server: server),
            child: const ControlPage(),
          );
        },
      ),
    );
  }

  void _getScreenControlPage(BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider<DisplayConnectionProvider>(
            create: (_) => DisplayConnectionProvider(server: server),
            child: const SwitchesScreenPage(),
          );
        },
      ),
    );
  }
   void _getDroneDataPage(BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider<DroneConnectionProvider>(
            create: (_) =>DroneConnectionProvider(server: server),
            child: const DroneDataPage(),
          );
        },
      ),
    );
  }

  void _getSnakeGameControlPage(BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider<SnakeConnectionProvider>(
            create: (_) => SnakeConnectionProvider(server: server),
            child: const SnakeControlPage(),
          );
        },
      ),
    );
  }

  void _getChatPage(BluetoothDevice server) {
    Navigator.of(context).push( 
      MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider<DisplayConnectionProvider>(
            create: (_) => DisplayConnectionProvider(server: server),
            child: const ChatPage(),
          );
        },
      ),
    );
  }
}

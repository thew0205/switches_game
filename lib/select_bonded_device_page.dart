// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'bluetooth_device_list_entry.dart';
import 'core/colors.dart';
import 'core/constant_widget.dart';
import 'switches_custom_loading_indicator.dart';

class SelectBondedDevicePage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const SelectBondedDevicePage({
    Key? key,
    required this.checkAvailability,
  }) : super(key: key);

  @override
  State<SelectBondedDevicePage> createState() => _SelectBondedDevicePage();
}

enum _DeviceAvailability {
  maybe,
  yes,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  List<_DeviceWithAvailability> devices =
      List<_DeviceWithAvailability>.empty(growable: true);

  // Availability
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool _isDiscovering = false;
  bool isConnecting = false;
  _SelectBondedDevicePage();

  @override
  void initState() {
    super.initState();

    _isDiscovering = widget.checkAvailability;
    future() async {
      if (!((await FlutterBluetoothSerial.instance.isEnabled) ?? false)) {
        await FlutterBluetoothSerial.instance.requestEnable();
        showTopSnackBar(
          context,
          const CustomSnackBar.success(
            backgroundColor: switchesColor,
            message: "Your bluetooth is now active.",
          ),
        );
      }
    }

    future().then((_) {
      
      if (_isDiscovering) {
        _startDiscovery();
      }

      // Setup a list of the bonded devices
      FlutterBluetoothSerial.instance
          .getBondedDevices()
          .then((List<BluetoothDevice> bondedDevices) {
        setState(() {
          devices = bondedDevices
              .map(
                (device) => _DeviceWithAvailability(
                  device,
                  widget.checkAvailability
                      ? _DeviceAvailability.maybe
                      : _DeviceAvailability.yes,
                ),
              )
              .toList();
        });
      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      Iterator i = devices.iterator;
      while (i.moveNext()) {
        var device = i.current;
        if (device.device == r.device) {
          device.availability = _DeviceAvailability.yes;
          device.rssi = r.rssi;
        }
      }
      setState(() {});
    });

    _discoveryStreamSubscription?.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices.map((device) {
      return BluetoothDeviceListEntry(
        device: device.device,
        rssi: device.rssi,
        enabled: device.availability == _DeviceAvailability.yes,
        onTap: () {
          Navigator.of(context).pop(device.device);
        },
      );
    }).toList();
    return IgnorePointer(
        ignoring: isConnecting,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Select device'),
            actions: <Widget>[
              _isDiscovering
                  ? const FittedBox(
                      child: SwitchesLoadingIndicator(),
                    )
                  : IconButton(
                      icon: const Icon(Icons.replay),
                      onPressed: _restartDiscovery,
                    )
            ],
          ),
          body: Stack(
            children: [
              if (isConnecting) switchesIndicator,
              ListView(children: list),
            ],
          ),
        ));
  }
}

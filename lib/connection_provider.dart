// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names, empty_catches
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class SnakeConnectionProvider extends ConnectionProvider {
  int _score = 0;
  int _speed = 0;
  bool _isPlaying = false;
  bool _isGameOver = true;

  SnakeConnectionProvider({required BluetoothDevice server})
      : super(server: server);

  @override
  Future<bool> sendData(String text) async {
    try {
      connection?.output.add(Uint8List.fromList(utf8.encode(text)));
      await connection?.output.allSent;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void _onDataReceived(Uint8List data) {
    try {
      String dataString = String.fromCharCodes(data).trim();
      final infos = dataString.split("\r\n");
      for (final info in infos) {
        final data = info.trim().split(",");
        for (var datum in data) {
          datum = datum.trim();
          int separatorIndex = datum.indexOf(":");
          if (separatorIndex != -1) {
            String key = datum.substring(0, separatorIndex).trim();
            String value = datum.substring(separatorIndex + 1).trim();
            switch (key) {
              case 's':
                score = int.parse(value.trim());
                break;
              case 'v':
                speed = int.parse(value.trim());
                break;
              case 'p':
                isPlaying = value.trim() == '1' ? true : false;
                break;
              case 'g':
                isGameOver = value.trim() == '1' ? true : false;
                break;
              default:
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  set speed(int tempSpeed) {
    _speed = tempSpeed;
    notifyListeners();
  }

  int get speed => _speed;

  set score(int tempScore) {
    _score = tempScore;
    notifyListeners();
  }

  int get score => _score;

  set isPlaying(bool tempIsPlaying) {
    _isPlaying = tempIsPlaying;
    notifyListeners();
  }

  bool get isPlaying => _isPlaying;

  set isGameOver(bool tempIsGameOver) {
    _isGameOver = tempIsGameOver;
    notifyListeners();
  }

  bool get isGameOver => _isGameOver;
}

class CarConnectionProvider extends ConnectionProvider {
  double _speed = 0;
  double _acceleration = 0;
  int _obstacleDistance = 0;
  double _distanceCovered = 0;

  CarConnectionProvider({required BluetoothDevice server})
      : super(server: server);

  @override
  Future<bool> sendData(String text) async {
    try {
      connection?.output.add(Uint8List.fromList(utf8.encode(text)));
      await connection?.output.allSent;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void _onDataReceived(Uint8List data) {
    String dataString = String.fromCharCodes(data).trim();
    final infos = dataString.split("\r\n");
    for (final info in infos) {
      final data = info.trim().split(",");
      for (var datum in data) {
        datum = datum.trim();
        int seperatorIndex = datum.indexOf(":");
        if (seperatorIndex != -1) {
          String key = datum.substring(0, seperatorIndex).trim();
          String value = datum.substring(seperatorIndex + 1).trim();
          if (key == 's') {
            setSpeed(int.parse(value.trim()));
          } else if (key == 'd') {
            obstacleDistance = int.parse(value.trim());
          }
        }
      }
    }
  }

  void setSpeed(int tempSpeed) {
    double temSpeed = tempSpeed.toDouble();

    final speed_rev_s = (temSpeed / slotCount) * (1000 / updateTime_ms);

    final speed_m_s = speed_rev_s * pi * tyreRadius / 100;
    acceleration = speed_m_s;
    _speed = speed_m_s;
    distanceCovered = speed_m_s;

    notifyListeners();
  }

  set distanceCovered(double speed) {
    _distanceCovered += (speed * updateTime_ms / 1000);
    notifyListeners();
  }

  double get distanceCovered => _distanceCovered;

  double get acceleration => _acceleration;

  set acceleration(double newSpeed) {
    _acceleration = (newSpeed - _speed) * (1000 / updateTime_ms);
    notifyListeners();
  }

  double get speed => _speed;
  set obstacleDistance(int tempObstacleDistance) {
    _obstacleDistance = tempObstacleDistance;
    notifyListeners();
  }

  int get obstacleDistance => _obstacleDistance;
  @override
  set isConnecting(bool tempIsConnecting) {
    _isConnecting = tempIsConnecting;
    notifyListeners();
  }

// ignore: constant_identifier_names
  static const updateTime_ms = 100;
  static const tyreRadius = 6.61;
  static const slotCount = 20 * 2;
}

class Message {
  int whom;
  String text;

  Message(this.whom, this.text);
}

class DisplayConnectionProvider extends ConnectionProvider {
  final List<Message> _messages = List<Message>.empty(growable: true);
  static const clientID = 0;

  DisplayConnectionProvider({required BluetoothDevice server})
      : super(server: server);

  @override
  Future<bool> sendData(String text) async {
    text = text.trim();

    if (text.isNotEmpty) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode("$text\r\n")));
        await connection!.output.allSent;

        messages = [Message(clientID, text)];
        return true;
      } catch (e) {
        // Ignore error, but notify state
        return false;
      }
    }
    return false;
  }

  String _messageBuffer = '';

  @override
  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (final byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;
    // print(a);
    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    if (backspacesCounter > 0) {
      _messageBuffer = _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter);
    }
    final String incomingData =
        _messageBuffer.trim() + String.fromCharCodes(buffer)
          ..trim();
    // print(buffer);
    // print(String.fromCharCodes(buffer));
    int index = incomingData.lastIndexOf('\r');
    if (index == -1) {
      _messageBuffer = incomingData;
    } else {
      _messageBuffer = incomingData.substring(index + 1);
      final completeIncomingData = incomingData.substring(0, index);
      print(completeIncomingData);
      final infos = completeIncomingData.split('\r');
      messages = infos.map((message) => Message(1, message.trim())).toList();
    }
    // if (index != -1) {
    //    = _messages
    //     ..add(_Message(
    //       1,
    //       backspacesCounter > 0
    //           ? _messageBuffer.substring(
    //               0, _messageBuffer.length - backspacesCounter)
    //           : _messageBuffer + incomingData.substring(0, index),
    //     ));
    //   _messageBuffer = incomingData.substring(index);
    // } else {
    //   _messageBuffer = (backspacesCounter > 0
    //       ? _messageBuffer.substring(
    //           0, _messageBuffer.length - backspacesCounter)
    //       : _messageBuffer + incomingData);
    // }
  }

  set messages(List<Message> message) {
    _messages.addAll(message);
    notifyListeners();
  }

  List<Message> get messages => _messages;
}

class DroneSensorInfo {
  final TimeOfDay time;
  final int AirHum;
  final int AirTemp;
  final int SoilPh;
  final int SoilHum;
  final int GasConc;
  const DroneSensorInfo({
    required this.time,
    required this.AirHum,
    required this.AirTemp,
    required this.SoilPh,
    required this.SoilHum,
    required this.GasConc,
  });

  factory DroneSensorInfo.fromString(String infoString) {
    final infos = infoString.trim().split(',');

    return DroneSensorInfo(
        time: TimeOfDay.now(),
        AirHum: int.parse(infos[1]),
        AirTemp: int.parse(infos[2]),
        SoilPh: int.parse(infos[3]),
        SoilHum: int.parse(infos[4]),
        GasConc: int.parse(infos[5]));
  }
  @override
  String toString() {
    return 'DroneSensorInfo(time: $time, AirHum: $AirHum, AirTemp: $AirTemp, SoilPh: $SoilPh, SoilHum: $SoilHum, GasConc: $GasConc)';
  }
}

class DroneConnectionProvider extends ConnectionProvider {
  final List<DroneSensorInfo> _sensorData =
      List<DroneSensorInfo>.empty(growable: true);

  DroneConnectionProvider({required BluetoothDevice server})
      : super(server: server);


  String _messageBuffer = '';

  @override
  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;
    // print(a);
    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    if (backspacesCounter > 0) {
      _messageBuffer = _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter);
    }
    final incomingData = _messageBuffer.trim() + String.fromCharCodes(buffer)
      ..trim();
    // print(buffer);
    // print(String.fromCharCodes(buffer));
    final index = incomingData.lastIndexOf('\r');
    if (index == -1) {
      _messageBuffer = incomingData;
    } else {
      _messageBuffer = incomingData.substring(index + 1);
      final completeIncomingData = incomingData.substring(0, index);
      try {
        sensorData = [DroneSensorInfo.fromString(incomingData)];
      } catch (e) {
       
      }
    }
  }

  set sensorData(List<DroneSensorInfo> tempSensorData) {
    _sensorData.addAll(tempSensorData);
    notifyListeners();
  }

  List<DroneSensorInfo> get sensorData => _sensorData;

  @override
  Future<bool> sendData(String text) {
    // TODO: implement sendData
    throw UnimplementedError();
  }
}

abstract class ConnectionProvider extends ChangeNotifier {
  final BluetoothDevice server;
  BluetoothConnection? connection;
  StreamSubscription<Uint8List>? _dataStreamSubscription;
  bool _isConnecting = true;
  bool _isConnected = false;
  Stream<MapEntry<String, bool>>? IsConnectedStream;
  final StreamController<MapEntry<String, bool>> _isConnectedStreamController =
      StreamController<MapEntry<String, bool>>();

  ConnectionProvider({required this.server}) {
    IsConnectedStream = _isConnectedStreamController.stream;
    connect();
  }

  void _onDataReceived(Uint8List data);

  Future<bool> sendData(String text);

  @mustCallSuper
  void connect() async {
    if (server.isConnected || isConnected == true) {
      isConnected = true;
      return;
    }

    try {
      connection = await BluetoothConnection.toAddress(server.address);
      if (connection != null) {
        isConnecting = false;
        final tempIsConnected = connection?.isConnected ?? false;
        _isConnectedStreamController
            .add(MapEntry(isConnectedKey, tempIsConnected));
        isConnected = tempIsConnected;
        _dataStreamSubscription = connection!.input!.listen(_onDataReceived);
        _dataStreamSubscription?.onDone(() {
          cancel();
        });
      } else {
        cancel();
      }
    } catch (error) {
      cancel();
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    _dataStreamSubscription?.cancel();
    connection?.dispose();
    super.dispose();
  }

  void reconnect() {
    cancel();
    isConnecting = false;
    connect();
  }

  @mustCallSuper
  void cancel() {
    isConnecting = false;
    isConnected = false;
    _isConnectedStreamController.add(const MapEntry(cannotConnectKey, true));
    _dataStreamSubscription?.cancel();
  }

  set isConnecting(bool tempIsConnecting) {
    _isConnecting = tempIsConnecting;
    notifyListeners();
  }

  static const isConnectedKey = "isConnected";
  bool get isConnecting => _isConnecting;

  bool get isConnected => _isConnected;

  set isConnected(bool tempIsConnected) {
    _isConnected = tempIsConnected;
  }

  static const cannotConnectKey = "cannotConnect";
}

//  n,           AirHumi,       AirTemp,          SoilPh,         SoilHumi,        GasConc
//   0,              71,             29,                7,             255,            94
//   1,              71,             29,                7,             255,            94
//   2,              71,             29,                7,             255,            94
//   3,              71,             29,                7,             255,            94
//   4,              71,             29,                7,             255,            94
//   5,              71,             29,                6,             255,            94
//   6,              71,             29,                6,             255,            94
//   7,              71,             29,                6,             255,            94

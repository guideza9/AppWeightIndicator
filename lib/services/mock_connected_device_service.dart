import 'dart:async';
import 'dart:math';
import 'package:hc05/model/accumulated_ticket.dart';
import 'package:hc05/model/print_ticket.dart';
import 'package:hc05/model/weight_data.dart';

import 'bluetooth_interface.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';

class MockConnectedDeviceService implements BluetoothInterface {
  bool _connected = false;
  late Function(String) _onDataReceived;
  final _random = Random();
  int _printCounter = 1;
  int _accCounter = 3; 
  double _accWeight = 134.55;

  @override
  bool get isConnected => _connected;

  @override
  Future<List<BluetoothDevice>> getBondedDevices() async {
    return [
      BluetoothDevice(
          name: 'Mock HC-05',
          address: '00:00:00:00:00:00',
          type: BluetoothDeviceType.classic),
    ];
  }

  @override
  Future<void> connectToDevice(
      BluetoothDevice device, Function(String) onDataReceived) async {
    _connected = true;
    _onDataReceived = onDataReceived;
  }

  @override
  void sendCommand(String command) {
    final cmd = command.trim().toUpperCase();

    double fluctuation = (_random.nextDouble() * 0.6) - 0.3;
    double weight = 45.0 + fluctuation;
    bool isStable = _random.nextBool();
    final response = WeightResponse(
      isStable: isStable,
      isGross: true,
      weight: double.parse(weight.toStringAsFixed(2)),
      unit: 'kg',
    );

    String responseStr;
    switch (cmd) {
      case 'T':
        responseStr = 'TARE OK\r\n';
        break;
      case 'Z':
        responseStr = 'ZERO OK\r\n';
        break;
      case 'P':
        final ticket = PrintTicket(
          no: _printCounter++,
          dateTime: DateTime.now(),
          grossWeight: weight,
          tareWeight: 2.88,
        );
        responseStr = ticket.format();
        break;
      case 'R':
        responseStr = response.toRawString();
        break;
      case 'TOTAL':
        final totalTicket = AccumulatedTicket(
          no: _printCounter++,
          dateTime: DateTime.now(),
          totalCount: _accCounter,
          totalWeight: _accWeight,
        );
        responseStr = totalTicket.format();
        break;
      default:
        responseStr = 'UNKNOWN COMMAND\r\n';
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      _onDataReceived(responseStr);
    });
  }

  @override
  void disconnect() {
    _connected = false;
  }
}

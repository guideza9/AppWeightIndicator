import 'dart:typed_data';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';
import 'bluetooth_interface.dart';

class RealBluetoothService implements BluetoothInterface {
  BluetoothConnection? _connection;
  bool get isConnected => _connection?.isConnected ?? false;

  @override
  Future<List<BluetoothDevice>> getBondedDevices() async {
    return FlutterBluetoothSerial.instance.getBondedDevices();
  }

  @override
  Future<void> connectToDevice(BluetoothDevice device, Function(String) onDataReceived) async {
    _connection = await BluetoothConnection.toAddress(device.address);
    _connection!.input!.listen((Uint8List data) {
      onDataReceived(String.fromCharCodes(data));
    });
  }

  @override
  void sendCommand(String command) {
    if (isConnected) {
      _connection!.output.add(Uint8List.fromList(command.codeUnits));
    }
  }

  @override
  void disconnect() {
    _connection?.dispose();
    _connection = null;
  }
}

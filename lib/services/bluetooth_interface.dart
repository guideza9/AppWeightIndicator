import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';

abstract class BluetoothInterface {
  bool get isConnected;
  Future<List<BluetoothDevice>> getBondedDevices();
  Future<void> connectToDevice(BluetoothDevice device, Function(String) onDataReceived);
  void sendCommand(String command);
  void disconnect();
}

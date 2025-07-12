import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';
import 'package:hc05/services/bluetooth_interface.dart';
import 'package:hc05/services/mock_connected_device_service.dart';
import 'services/bluetooth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BluetoothPage(),
    );
  }
}

enum DeviceMode { mock, real }

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});
  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  DeviceMode _selectedMode = DeviceMode.mock;
  late BluetoothInterface _bluetoothService;
  String receivedData = "";
  bool isConnected = false;

  void initService() {
    _bluetoothService = _selectedMode == DeviceMode.real
        ? RealBluetoothService()
        : MockConnectedDeviceService();
  }

  void connectToDevice(BluetoothDevice device) async {
    await _bluetoothService.connectToDevice(device, (String data) {
      setState(() {
        receivedData += data;
      });
    });
    setState(() => isConnected = _bluetoothService.isConnected);
  }

  void listDevices() async {
    final devices = await _bluetoothService.getBondedDevices();
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text("เลือกอุปกรณ์"),
        children: devices.map((device) {
          return SimpleDialogOption(
            child: Text(device.name ?? device.address),
            onPressed: () {
              Navigator.pop(context);
              connectToDevice(device);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initService();
  }

  void send(String command) {
    _bluetoothService.sendCommand(command);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Weighing"),
        actions: [
          DropdownButton<DeviceMode>(
            value: _selectedMode,
            onChanged: (mode) {
              setState(() {
                _selectedMode = mode!;
                initService();
                receivedData = "";
                isConnected = false;
              });
            },
            items: const [
              DropdownMenuItem(
                  value: DeviceMode.mock, child: Text("Mock Device")),
              DropdownMenuItem(
                  value: DeviceMode.real, child: Text("Real Device")),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
                onPressed: listDevices, child: const Text("เชื่อมต่ออุปกรณ์")),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                    onPressed: isConnected ? () => send("T") : null,
                    child: const Text("Tare")),
                ElevatedButton(
                    onPressed: isConnected ? () => send("Z") : null,
                    child: const Text("Zero")),
                ElevatedButton(
                    onPressed: isConnected ? () => send("P") : null,
                    child: const Text("Print")),
                ElevatedButton(
                    onPressed: isConnected ? () => send("R") : null,
                    child: const Text("Read")),
                ElevatedButton(
                    onPressed: isConnected ? () => send("TOTAL") : null,
                    child: const Text("TOTAL")),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(child: Text(receivedData)),
            ),
          ],
        ),
      ),
    );
  }
}

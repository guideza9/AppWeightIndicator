import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';

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

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});
  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  BluetoothConnection? connection;
  String deviceAddress = "";
  String receivedData = "";
  bool isConnected = false;

  void connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection.toAddress(device.address).then((_connection) {
        connection = _connection;
        setState(() => isConnected = true);

        connection!.input!.listen((data) {
          setState(() {
            receivedData += String.fromCharCodes(data);
          });
        });
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void listDevices() async {
    final bondedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text("เลือกอุปกรณ์ HC-05"),
        children: bondedDevices.map((device) {
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
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  void sendCommand(String command) {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(command.codeUnits));
      connection!.output.allSent.then((_) {
        print('✅ Sent: $command');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ชั่งน้ำหนักผ่าน HC-05")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: listDevices,
              child: const Text("เชื่อมต่อ HC-05"),
            ),
            const SizedBox(height: 20),
            Text(
              isConnected ? "เชื่อมต่อแล้ว" : "ยังไม่เชื่อมต่อ",
              style: TextStyle(color: isConnected ? Colors.green : Colors.red),
            ),
            const SizedBox(height: 20),
            const Text("ข้อมูลจากเครื่องชั่ง:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  receivedData,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: isConnected ? () => sendCommand("T\r\n") : null,
                  child: const Text("Tare (T)"),
                ),
                ElevatedButton(
                  onPressed: isConnected ? () => sendCommand("Z\r\n") : null,
                  child: const Text("Zero (Z)"),
                ),
                ElevatedButton(
                  onPressed: isConnected ? () => sendCommand("P\r\n") : null,
                  child: const Text("Print (P)"),
                ),
                ElevatedButton(
                  onPressed: isConnected ? () => sendCommand("R\r\n") : null,
                  child: const Text("Read (R)"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

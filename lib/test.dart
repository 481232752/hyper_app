import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

// void main() {
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];
  late BluetoothDevice connectedDevice;
  late BluetoothCharacteristic characteristic;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((scanResult) {
      for (ScanResult result in scanResult) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
    // Discover services and characteristics
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      service.characteristics.forEach((characteristic) {
        // Find your characteristic and store it for future use
        // if (characteristic.uuid == YOUR_CHARACTERISTIC_UUID) {
        //   setState(() {
        //     this.characteristic = characteristic;
        //   });
        // }
      });
    });
  }

  void _sendMessage() {
    if (connectedDevice != null && characteristic != null) {
      // Write your data to the characteristic
      //characteristic.write([YOUR_DATA]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Example'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devices[index].name),
            onTap: () {
              _connectToDevice(devices[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        child: Icon(Icons.send),
      ),
    );
  }
}

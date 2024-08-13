import 'dart:io';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Network Scanner')),
        body: NetworkScanner(),
      ),
    );
  }
}

class NetworkScanner extends StatefulWidget {
  @override
  _NetworkScannerState createState() => _NetworkScannerState();
}

class _NetworkScannerState extends State<NetworkScanner> {
  List<String> _availableServers = [];
  final String _subnet = '192.168.0'; // Replace with your subnet
  final TextEditingController _portController = TextEditingController();
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _portController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter Port Number',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _scanNetwork(),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isScanning ? null : _scanNetwork,
            child: Text(_isScanning ? 'Scanning...' : 'Scan Network'),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _availableServers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Server found at: ${_availableServers[index]}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanNetwork() async {
    setState(() {
      _availableServers.clear();
      _isScanning = true;
    });

    final port = int.tryParse(_portController.text) ?? 1883;
    List<String> servers = [];

    for (int i = 1; i < 255; i++) {
      final ip = '$_subnet.$i';
      final result = await _ping(ip, port);
      if (result) {
        servers.add(ip);
      }
    }

    setState(() {
      _availableServers = servers;
      _isScanning = false;
    });
  }

  Future<bool> _ping(String ip, int port) async {
    try {
      final socket =
          await Socket.connect(ip, port, timeout: Duration(milliseconds: 1));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
}

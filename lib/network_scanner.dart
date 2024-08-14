import 'dart:io';
import 'package:flutter/material.dart';
import 'mqtt_page.dart';

class NetworkScanner extends StatefulWidget {
  @override
  _NetworkScannerState createState() => _NetworkScannerState();
}

class _NetworkScannerState extends State<NetworkScanner> {
  List<String> _availableServers = [];
  final TextEditingController _subnetController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  bool _isScanning = false;
  String _subnet = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _subnetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter Subnet (e.g., 192.168.0)',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _startScan(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _portController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter Port Number (e.g., 1883)',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _startScan(),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isScanning ? null : _startScan,
            child: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _isScanning
                ? Center(child: CircularProgressIndicator())
                : _availableServers.isEmpty
                    ? Center(child: Text('No servers found.'))
                    : ListView.builder(
                        itemCount: _availableServers.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                                'Server found at: ${_availableServers[index]}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MqttPage(ip: _availableServers[index]),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _startScan() {
    setState(() {
      _subnet =
          _subnetController.text == "" ? "192.168.0" : _subnetController.text;
      _availableServers.clear();
      _isScanning = true;
    });

    final port = int.tryParse(_portController.text) ?? 1883;
    _scanNetwork(port);
  }

  Future<void> _scanNetwork(int port) async {
    final futures = <Future<bool>>[];

    for (int i = 1; i < 255; i++) {
      final ip = '$_subnet.$i';
      futures.add(_ping(ip, port));
    }

    final results = await Future.wait(futures);
    final servers = <String>[];

    for (int i = 0; i < results.length; i++) {
      if (results[i]) {
        servers.add('$_subnet.${i + 1}');
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
          await Socket.connect(ip, port, timeout: Duration(milliseconds: 500));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
}

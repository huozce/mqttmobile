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
          getNetworkField(_subnetController, 'Enter Subnet (e.g., 192.168.0)'),
          const SizedBox(height: 16),
          getNetworkField(_portController, 'Enter Port Number (e.g., 1883)'),
          SizedBox(height: 16),
          getScanButton(),
          SizedBox(height: 16),
          Expanded(
            child: getFoundServers(),
          ),
        ],
      ),
    );
  }

  Widget getFoundServers() {
    return _isScanning
        ? Center(child: CircularProgressIndicator())
        : _availableServers.isEmpty
            ? Center(child: Text('No servers found.'))
            : ListView.builder(
                itemCount: _availableServers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Server found at: ${_availableServers[index]}'),
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
              );
  }

  ElevatedButton getScanButton() {
    return ElevatedButton(
      onPressed: _isScanning ? null : _startScan,
      child: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
    );
  }

  TextField getNetworkField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      onSubmitted: (_) => _startScan(),
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
    List<Future<bool>> futures = pingIPs(port);
    List<String> servers = await addFoundIPs(futures);
    setState(() {
      _availableServers = servers;
      _isScanning = false;
    });
  }

  Future<List<String>> addFoundIPs(List<Future<bool>> futures) async {
    final results = await Future.wait(futures);
    final servers = <String>[];

    for (int i = 0; i < results.length; i++) {
      if (results[i]) {
        servers.add('$_subnet.${i + 1}');
        // Vibration.vibrate(duration: 55);
      }
    }
    return servers;
  }

  List<Future<bool>> pingIPs(int port) {
    final futures = <Future<bool>>[];

    for (int i = 1; i < 255; i++) {
      final ip = '$_subnet.$i';
      futures.add(_ping(ip, port));
    }
    return futures;
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

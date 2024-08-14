import 'package:flutter/material.dart';
import 'mqtt_service.dart';

class MqttPage extends StatefulWidget {
  final String ip;

  MqttPage({required this.ip});

  @override
  _MqttPageState createState() => _MqttPageState();
}

class _MqttPageState extends State<MqttPage> {
  final MqttService _mqttService = MqttService();

  String _statusMessage = 'Connecting to MQTT topics...';

  @override
  void initState() {
    super.initState();
    _mqttService.broker = widget.ip;
    _connectToMqtt();
  }

  void _connectToMqtt() async {
    await _mqttService.initialize();
    bool success = true;

    success &= await _subscribeAndHandle("#");

    setState(() {
      _statusMessage = success
          ? 'Connected to all topics successfully!'
          : 'Failed to connect to some topics.';
    });
  }

  Future<bool> _subscribeAndHandle(String topic) async {
    bool success = await _mqttService.subscribeToTopic(topic, (topic, message) {
      setState(() {
        _mqttService.subscribedData.value[topic] = message;
      });
    });
    if (!success) {
      setState(() {
        _mqttService.subscribedData.value[topic] = 'Subscription failed';
      });
    }
    return success;
  }

  @override
  void dispose() {
    _mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT Subscribed Topics'),
      ),
      body: ValueListenableBuilder(
        valueListenable: _mqttService.subscribedData,
        builder: (context, value, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_statusMessage),
              ),
              Expanded(
                child: _mqttService.subscribedData.value.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView(
                        children: _mqttService.subscribedData.value.entries
                            .map((entry) {
                          return ListTile(
                            title: Text('${entry.key}: ${entry.value}'),
                          );
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

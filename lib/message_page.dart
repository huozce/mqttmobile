import 'package:flutter/material.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'mqtt_service.dart';

class MessagePage extends StatefulWidget {
  final String ip;

  MessagePage({required this.ip});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
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
      if (success) {
        _statusMessage = 'Connected to all topics successfully!';
      } else {
        _statusMessage = 'Failed to connect to some topics.';
      }
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
              getConnectionStatus(),
              Expanded(
                child: getMessages(context),
              ),
            ],
          );
        },
      ),
    );
  }

  TextEditingController cb = TextEditingController();

  Widget getMessages(BuildContext context) {
    return _mqttService.subscribedData.value.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchableList<MapEntry<String, String>>(
              searchTextController: cb,
              initialList: _mqttService.subscribedData.value.entries.toList(),
              itemBuilder: (MapEntry<String, String> entry) => ListTile(
                title: Text(
                    '${entry.key.split("/").first}:${entry.key.split("/").last}: ${entry.value}'),
                onTap: () {
                  showPopup(context, entry.key);
                },
              ),
              filter: (value) => _mqttService.subscribedData.value.entries
                  .where((entry) =>
                      entry.key.toLowerCase().contains(value.toLowerCase()) ||
                      entry.value.toLowerCase().contains(value.toLowerCase()))
                  .toList(),
              emptyWidget: const Text("Empty"),
              inputDecoration: InputDecoration(
                labelText: "Search",
                border: OutlineInputBorder(),
              ),
            ),
          );
  }

  Padding getConnectionStatus() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(_statusMessage),
    );
  }

  void showPopup(BuildContext context, String topic) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Value'),
          content: TextField(
            controller: _mqttService.valueController,
          ),
          actions: <Widget>[
            cancelPopUp(context),
            okPopUp(topic, context),
          ],
        );
      },
    );
  }

  TextButton okPopUp(String topic, BuildContext context) {
    return TextButton(
      child: Text('OK'),
      onPressed: () {
        // Perform some action
        if (_mqttService.valueController.text.isNotEmpty)
          _mqttService.publishMessage(topic);
        _mqttService.valueController.clear();
        Navigator.of(context).pop(); // Close the dialog
      },
    );
  }

  TextButton cancelPopUp(BuildContext context) {
    return TextButton(
      child: Text('Cancel'),
      onPressed: () {
        _mqttService.valueController.clear();
        Navigator.of(context).pop(); // Close the dialog
      },
    );
  }
}

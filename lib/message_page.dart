import 'package:denememqttscan/showPopUp.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'mqtt_service.dart';

class MessagePage extends StatefulWidget {
  final String ip;

  MessagePage({required this.ip});

  @override
  _MessagePageState createState() => _MessagePageState();
}

String selectedValue = "";
void dropDownCallback(MqttQos) {}

class Popupgenerator extends StatefulWidget {
  const Popupgenerator({
    super.key,
    this.mqttService,
    this.baslik,
  });
  final mqttService;
  final baslik; //topic name

  @override
  State<Popupgenerator> createState() => _PopupgeneratorState();
}

class _PopupgeneratorState extends State<Popupgenerator> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(' Value'),
      content: TextField(
        controller: widget.mqttService.valueController,
      ),
      actions: <Widget>[
        DropdownButton(
          items: const [
            DropdownMenuItem(child: Text("Qos0"), value: MqttQos.atMostOnce),
            DropdownMenuItem(child: Text("Qos1"), value: MqttQos.atLeastOnce),
            DropdownMenuItem(child: Text("Qos2"), value: MqttQos.exactlyOnce),
          ],
          value: MqttService.selectedQos,
          onChanged: (value) {
            setState(() {
              if (value != null) MqttService.selectedQos = value;
            });
          },
        ),
        cancelPopUp(context),
        okPopUp(widget.baslik, context),
      ],
    );
    ;
  }

  TextButton okPopUp(String topic, BuildContext context) {
    return TextButton(
      child: Text('OK'),
      onPressed: () {
        // Perform some action
        if (widget.mqttService.valueController.text.isNotEmpty)
          widget.mqttService.publishMessage(topic);
        widget.mqttService.valueController.clear();
        Navigator.of(context).pop(); // Close the dialog
      },
    );
  }

//Cancel Butonu
  TextButton cancelPopUp(BuildContext context) {
    return TextButton(
      child: Text('Cancel'),
      onPressed: () {
        widget.mqttService.valueController.clear();
        Navigator.of(context).pop(); // Close the dialog
      },
    );
  }
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

    success &= await _subscribeAndHandle("#"); //Subsribes to all topics

    setState(() {
      if (success) {
        _statusMessage = 'Connected to all topics successfully!';
      } else {
        _statusMessage = 'Failed to connect to topics.';
      }
    });
  }

  Future<bool> _subscribeAndHandle(String topic) async {
    //state of the connection
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
                child: Messages(
                  mqttService: _mqttService,
                  cb: cb,
                  showPopUp: showPopup,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  TextEditingController cb = TextEditingController();

  Padding getConnectionStatus() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(_statusMessage),
    );
  }

  void showPopup(BuildContext context, MapEntry<String, String> entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Popupgenerator(
          mqttService: _mqttService,
          baslik: entry.key,
        );
      },
    );
  }

//OK Butonu
}

class Messages extends StatefulWidget {
  const Messages(
      {super.key, required this.mqttService, this.cb, this.showPopUp});
  final MqttService mqttService;
  final showPopUp;
  final cb;

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    return widget.mqttService.subscribedData.value.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchableList<MapEntry<String, String>>(
              searchTextController: widget.cb,
              initialList:
                  widget.mqttService.subscribedData.value.entries.toList(),
              itemBuilder: (MapEntry<String, String> entry) =>
                  !(entry.value == 'Subscription failed')
                      ? ListTile(
                          title: Text(
                            '${entry.key.split("/").first.split(" ").first}:${entry.key.split(" ").last.split("/").last}: ${entry.value.split("/").first}',
                          ),
                          onTap: () {
                            // if (!(entry.value == 'Subscription failed'))
                            widget.showPopUp(context, entry);
                          },
                        )
                      : Text(entry.value),
              filter: (value) => widget.mqttService.subscribedData.value.entries
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
}

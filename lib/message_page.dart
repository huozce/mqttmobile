import 'package:denememqttscan/freePopup.dart';
import 'package:denememqttscan/messagestate.dart';
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

    success &= await _subscribeAndHandle(
        "#"); //Tüm topiclere abone olunması işlemi "#" topicine abone olmakla gerçekleşir.

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
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Popupgenerator(
                      x: false,
                      baslik: "",
                      mqttService: _mqttService,
                      title: "Text entry",
                    );
                  },
                );
              },
              icon: Text("özgürce yaz"))
        ],
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
          title: "Value",
          x: true,
        );
      },
    );
  }

//OK Butonu
}

String selectedValue = "";
void dropDownCallback(MqttQos) {}

// class FreePopUp extends StatefulWidget {
//   const FreePopUp({super.key});

//   @override
//   State<FreePopUp> createState() => _FreePopUpState();
// }

// class _FreePopUpState extends State<FreePopUp> {
//   @override
//   Widget build(BuildContext context) {
//     return Popupgenerator(
//       title: "ssdasd",
//     );
//   }
// }

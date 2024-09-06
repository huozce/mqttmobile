import 'package:denememqttscan/mqtt_service.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

class Popupgenerator extends StatefulWidget {
  Popupgenerator(
      {super.key,
      this.mqttService,
      this.baslik,
      required this.title,
      required this.x});
  final mqttService;
  final baslik; //topic name
  final title;
  bool x;

  @override
  State<Popupgenerator> createState() => _PopupgeneratorState();
}

class _PopupgeneratorState extends State<Popupgenerator> {
  Widget widgetreturner(bool x) {
    if (x == true) {
      return TextField(controller: widget.mqttService.valueController);
    } else {
      return Column(
        children: [
          TextField(controller: widget.mqttService.topicController),
          TextField(controller: widget.mqttService.valueController)
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: widgetreturner(widget.x),
      actions: <Widget>[
        DropdownButton(
          //Gönderilen mesaj tipini belirlememiz sağlanır .
          items: const [
            DropdownMenuItem(child: Text("Qos0"), value: MqttQos.atMostOnce),
            DropdownMenuItem(child: Text("Qos1"), value: MqttQos.atLeastOnce),
            DropdownMenuItem(child: Text("Qos2"), value: MqttQos.exactlyOnce),
          ],
          value: MqttService.selectedQos,
          onChanged: (QosVal) {
            setState(() {
              if (QosVal != null) MqttService.selectedQos = QosVal;
            });
          },
        ),
        cancelPopUp(context),
        okPopUp(widget.baslik, context),
      ],
    );
  }

  TextButton okPopUp(String topic, BuildContext context) {
    //OK Butonunun işlevi
    return TextButton(
      child: Text('OK'),
      onPressed: () {
        // Perform some action
        if (widget.mqttService.valueController.text.isNotEmpty &&
            widget.x == true) {
          widget.mqttService.publishMessage(topic);
          widget.mqttService.valueController.clear();
        } else {
          widget.mqttService.publishMessageFreely(topic, value);
        }

        Navigator.of(context).pop(); // Close the dialog
      },
    );
  }

//Cancel Butonu
  TextButton cancelPopUp(BuildContext context) {
    // Cancel butonunun işlevi
    return TextButton(
      child: Text('Cancel'),
      onPressed: () {
        widget.mqttService.valueController.clear();
        Navigator.of(context).pop(); // Close the dialog
      },
    );
  }
}

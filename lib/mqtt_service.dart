import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

class MqttService {
  ValueNotifier<Map<String, String>> subscribedData = ValueNotifier({});
  MqttServerClient? client;
  String broker = ''; // To be set dynamically
  final int port = 1883;
  String globalPayload = "";
  TextEditingController valueController = TextEditingController();
  Future<void> initialize() async {
    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      return; // Already connected
    }

    client = MqttServerClient(broker, '');
    client?.port = port;
    client?.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client?.connectionMessage = connMessage;

    try {
      await client?.connect();
      client?.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        String payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        globalPayload = payload;
        /*String tag = jsonDecode(payload)["tag"].toString();
        List<String> splittedTag = tag.split("/");*/
        List<String> id = c[0].topic.split("/");
        String value = jsonDecode(payload)["value"].toString();
        _handleMessage(c[0].topic, value.isEmpty ? "Null" : value);
      });
    } catch (e) {
      print('Exception: $e');
      client?.disconnect();
    }
  }

  Future<bool> subscribeToTopic(
      String topic, Function(String, String) handler) async {
    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      try {
        client?.subscribe(topic, MqttQos.atMostOnce);
        return true;
      } catch (e) {
        print('Subscription failed for topic $topic: $e');
        return false;
      }
    }
    return false;
  }

  void _handleMessage(String topic, String value) {
    // You can implement the logic to handle the message based on the topic and tag
    // Implement additional logic as needed
    subscribedData.value.addEntries([MapEntry("$topic", "$value")]);
    subscribedData.notifyListeners();
  }

  void publishMessage(String topic) {
    if (client?.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      String value = valueController.text;
      List<String> tag = topic.split("/");
      String atag = tag.last;
      final jsonMessage =
          '{"tag": "Application/MQTT_tags/$atag", "value":$value}';
      builder.addString(jsonMessage);
      client?.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      print('Client is not connected');
    }
  }

  void disconnect() {
    client?.disconnect();
  }
}

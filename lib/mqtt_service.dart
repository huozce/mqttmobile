import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import 'mqtt_page.dart';

class MqttService {
  ValueNotifier<Map<String, String>> subscribedData = ValueNotifier({});
  MqttServerClient? client;
  String broker = ''; // To be set dynamically
  final int port = 1883;
  String zort = "";

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
        zort = payload;
        String tag = jsonDecode(payload)["tag"].toString();
        List<String> splittedTag = tag.split("/");
        String value = jsonDecode(payload)["value"].toString();
        _handleMessage(splittedTag.last, value.isEmpty ? "Null" : value);
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

  void _handleMessage(String tag, String value) {
    // You can implement the logic to handle the message based on the topic and tag

    // Implement additional logic as needed
    subscribedData.value.addEntries([MapEntry("$tag", "$value")]);
    subscribedData.notifyListeners();
  }

  void disconnect() {
    client?.disconnect();
  }
}

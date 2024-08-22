// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:denememqttscan/message_page.dart';
import 'package:denememqttscan/network_scanner.dart';
import 'package:denememqttscan/showPopUp.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import 'package:denememqttscan/network_scanner.dart';

class MqttService {
  static MqttQos selectedQos = MqttQos.atLeastOnce;
  NetworkScanner _networkScanner = NetworkScanner();
  ValueNotifier<Map<String, String>> subscribedData =
      ValueNotifier({}); //notifies when a value changes.
  MqttServerClient? client;
  String broker = ''; // To be set dynamically
  // final int port = zart;
  static String nick = "";
  static String userPort = "";
  String globalPayload = "";
  TextEditingController valueController = TextEditingController();

  static String messageTag = "";

  static String TopicTest = "";

  Future<void> initialize() async {
    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      return; // Already connected
    }
    initClient();
    await listenMessage();
  }

  void initClient() {
    client = MqttServerClient(broker, '');

    client?.clientIdentifier = nick;
    client?.port = int.parse(userPort);
    client?.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(client!.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client?.connectionMessage = connMessage;
  }

  Future<void> listenMessage() async {
    try {
      await client?.connect(Showpopup.controll1.text, Showpopup.controll2.text);
      client?.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        messageTag = parseMessage(c, "tag");
        TopicTest = c[0].topic;

        String value = parseMessage(c, "value");

        _handleMessage(
            "${c[0].topic} $messageTag", value.isEmpty ? "Null" : value);
      });
    } catch (e) {
      print('Exception: $e');
      client?.disconnect();
    }
  }

  String parseMessage(List<MqttReceivedMessage<MqttMessage>> c, String key) {
    MqttPublishMessage message = c[0].payload as MqttPublishMessage;
    String payload =
        MqttPublishPayload.bytesToStringAsString(message.payload.message);
    return jsonDecode(payload)[key].toString();
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
    // ignore: invalid_use_of_protected_member
    subscribedData.notifyListeners();
  }

  void publishMessage(
    String topic,
  ) {
    if (client?.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      String value = valueController.text;

      String tag = topic.split(" ").last;
      topic = topic.split(" ").first;

      final jsonMessage = '{"tag": "$tag", "value":"$value"}';

      builder.addString(jsonMessage);
      client?.publishMessage(topic, selectedQos, builder.payload!);
    } else {
      print('Client is not connected');
    }
  }

  void disconnect() {
    client?.disconnect();
    clearControllers();
  }

  static void clearControllers() {
    Showpopup.controll1.clear();
    Showpopup.controll2.clear();
  }
}

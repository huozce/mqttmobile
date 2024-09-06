// Bu sayfada MQTT brokerına bağlanmak için gerekli bilgilerin girilmesi için gerekli kütüphaneler çağırılır.
//Mesajların okunup gönderilmesi yönetilir.
//Getirilen Mesajlar parselanmış bir şekilde uygulamaya ulaştırılır. Ve json formatında brokera gönderilir.
//(Panelin yönetimi json formatı üzerinden haberleşmeyle gerçekleştirilir.)

import 'package:denememqttscan/message_page.dart';
import 'package:denememqttscan/network_scanner.dart';
import 'package:denememqttscan/showPopUp.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import 'package:denememqttscan/network_scanner.dart';

String value = "";

class MqttService {
  static MqttQos selectedQos = MqttQos.atLeastOnce;
  NetworkScanner _networkScanner = NetworkScanner();
  ValueNotifier<Map<String, String>> subscribedData =
      ValueNotifier({}); //Bir değer değiştiğinde bilgilendirir.
  MqttServerClient? client;
  String broker = ''; // Değiştirilebilirdir.
  // final int port = zart;
  static String nick = "";
  static String userPort = "";
  String globalPayload = "";
  TextEditingController valueController =
      TextEditingController(); //changing the value of listened things
  TextEditingController topicController = TextEditingController();

  static String messageTag = "";

  static String TopicTest = "";
//Kullanıcı bağlı statüsüne geçerse fonksiyon çıksın, tekrar bağlanmayı denemesin.
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
    client?.port = int.parse(
        userPort); // Kullanıcı broker hangi porttaysa kendi Ip'sinin o değerdeki portuyla brokera bağlanır.(Parametrik olarak düzenlenmemiştir.)
    client?.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(client!.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client?.connectionMessage = connMessage;
  }

  Future<void> listenMessage() async {
    try {
      await client?.connect(
          Showpopup.controll1.text,
          Showpopup.controll2
              .text); //önce kullanıcı adı ve şifreyi bekler ve onların içine girilen değerlerle bağlantı yapmaya çalışır.Dolayısıyla fonksiyonun aldığı parametreler kullanıcı adı ve şifredir.
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
    //Mesajların parse edilmesi.
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
    subscribedData.value.addEntries([MapEntry("$topic", "$value")]);

    subscribedData.notifyListeners();
  }

//belirlenen topice aynı yerden geri mesaj yollar.(mesaj alınan yerden mesaj yollanır.)
  void publishMessageFreely(String topic, String value) {
    if (client?.connectionStatus!.state == MqttConnectionState.connected) {
      value = valueController.text;
      topic = topicController.text;

      final builder = MqttClientPayloadBuilder();
      builder.addString(value);
      client?.publishMessage(topic, selectedQos, builder.payload!);
    } else {
      print('Client is not connected');
    }
  }

  void publishMessage(
    String topic,
  ) {
    if (client?.connectionStatus!.state == MqttConnectionState.connected) {
      //eğer client bağlıysa valuecontrollerın textine girilmiş şey value ya aktarılır.

      final builder = MqttClientPayloadBuilder();
      value = valueController.text;

      String tag = topic.split(" ").last;
      topic = topic.split(" ").first;

      final jsonMessage = '{"tag": "$tag", "value":"$value"}';

      builder.addString(
          jsonMessage); //json formatında gelen mesaj builderın içine yazılır
      client?.publishMessage(
          topic,
          selectedQos,
          builder
              .payload!); //Nihayetinde belirlenmiş Qos'te yollanacak mesaj belirlenen topicte Json formatında yollanılır.
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

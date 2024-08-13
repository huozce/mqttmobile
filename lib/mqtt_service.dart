import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  MqttServerClient? client;
  String broker = ''; // To be set dynamically
  final int port = 1883;
  final Map<String, void Function(String, String)> _messageHandlers = {};

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
        final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        final String topic = c[0].topic;
        final String payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        if (_messageHandlers.containsKey(topic)) {
          _messageHandlers[topic]?.call(topic, payload);
        }
      });
    } catch (e) {
      print('Exception: $e');
      client?.disconnect();
    }
  }

  Future<bool> subscribeToTopic(
      String topic, Function(String, String) handler) async {
    _messageHandlers[topic] = handler;
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

  void disconnect() {
    client?.disconnect();
  }
}

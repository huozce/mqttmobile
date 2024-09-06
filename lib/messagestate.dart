import 'package:denememqttscan/mqtt_service.dart';
import 'package:flutter/material.dart';
import 'package:searchable_listview/searchable_listview.dart';

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

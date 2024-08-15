import 'package:denememqttscan/message_page.dart';
import 'package:denememqttscan/mqtt_service.dart';
import 'package:flutter/material.dart';

class Showpopup {
  static TextEditingController controll1 = TextEditingController();
  static TextEditingController controll2 = TextEditingController();
  Showpopup(BuildContext context, String label1, String label2, String reqIP) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Value'),
          content: Column(
            children: [
              TextField(
                controller: controll1,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: label1,
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: controll2,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: label2,
                  border: OutlineInputBorder(),
                ),
              )
            ],
          ),
          actions: <Widget>[
            cancelPopUp(context),
            okPopUp(context, reqIP),
          ],
        );
      },
    );
  }

  TextButton okPopUp(BuildContext context, String reqIP) {
    return TextButton(
      child: Text('OK'),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagePage(ip: reqIP),
          ),
        );
        // Perform some action// Close the dialog
      },
    );
  }

  TextButton cancelPopUp(BuildContext context) {
    return TextButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.of(context).pop(); // Close the dialog
      },
    );
  }
}

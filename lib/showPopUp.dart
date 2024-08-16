import 'package:denememqttscan/message_page.dart';
import 'package:denememqttscan/mqtt_service.dart';
import 'package:flutter/material.dart';

class Showpopup {
  static TextEditingController controll1 = TextEditingController();
  static TextEditingController controll2 = TextEditingController();
  Showpopup(BuildContext context, String label1, String label2, String reqIP) {
    bool _isObscured2 = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: AlertDialog(
                  title: Text('Enter Value'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controll1,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: label1,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: controll2,
                        keyboardType: TextInputType.text,
                        obscureText: _isObscured2,
                        decoration: InputDecoration(
                          labelText: label2,
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured2
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured2 = !_isObscured2;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    cancelPopUp(context),
                    okPopUp(context, reqIP),
                  ],
                ),
              ),
            );
          },
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

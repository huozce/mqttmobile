import 'package:denememqttscan/message_page.dart';
import 'package:denememqttscan/mqtt_service.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

// Bu bölümde açılan popupın içi ve işlevleri gösterilmiştir.
//Kullanıcı adı ve şifre girilen popup burada gösterilmiştir.

class Showpopup {
  static TextEditingController controll1 = TextEditingController();
  static TextEditingController controll2 = TextEditingController();
  static TextEditingController controll3 = TextEditingController();
  Showpopup(BuildContext context, String label1, String label2, String reqIP) {
    //label 1 ve label 2 kullanıcı adı ve şifreyi temsil eder.reqIp ise bağlanılan serverı temsil eder.
    bool _isObscured2 =
        true; //Şifre gösteriminin yıldızlı olup olmamasıyla ilgili değişkenin ilkin ataması

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
                        controller:
                            controll1, //control1 e kullanıcı adı girilmektedir dolayısıyla labeltext olarak da label1 de username yazmaktadır.
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: label1,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller:
                            controll2, // control 2 ye şifre girilir dolayısıyla yıldızlı gösterilmesi uygun görülmüştür.label2 de password yazmaktadır.
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
    //Popup'daki ok butonu ne işe yarar
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
      },
    );
  }

  TextButton cancelPopUp(BuildContext context) {
    //Popup'daki cancel butonu ne işe yarar
    return TextButton(
      child: Text('Cancel'),
      onPressed: () {
        MqttService.clearControllers();
        Navigator.of(context).pop(); // Close the dialog
      },
    );
  }
}

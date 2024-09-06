import 'dart:io';
import 'package:denememqttscan/mqtt_service.dart';
import 'package:denememqttscan/showPopUp.dart';
import 'package:flutter/material.dart';
//Bu bölüm ağa bağlanmış IP'leri ve portları sorgular.

class NetworkScanner extends StatefulWidget {
  @override
  _NetworkScannerState createState() => _NetworkScannerState();
}

class _NetworkScannerState extends State<NetworkScanner> {
  List<String> _availableServers = [];
  final TextEditingController _subnetController =
      TextEditingController(); //Subnet olarak
  final TextEditingController _portController =
      TextEditingController(); //Port değerinin girildiği bölümdür.
  final TextEditingController _nickController = TextEditingController();
  bool _isScanning = false;
  String _subnet = '';
  String nick =
      "noName"; //Eğer isim ilerleyen bölümde değiştirilmezse noName olarak girecektir.Ancak brokera iki kişi aynı isimler bağlanırsa ilk bağlananın bağlantısı kopar.

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          getNetworkField(_subnetController, 'Enter Subnet (e.g., 192.168.0)'),
          const SizedBox(height: 16),
          getNetworkField(_portController,
              'Enter Port Number (e.g., 1883)'), //Eğer boş girilirse 1883 olarak belirlenecektir port.Değerini _portController dan alır.
          SizedBox(height: 16),
          getNetworkField(_nickController,
              'Enter Username'), //Kullanıcının nicki default kalmasın diye eklenmiştir.
          getScanButton(),
          Expanded(
            child: getFoundServers(),
          ),
        ],
      ),
    );
  }

  Widget getFoundServers() {
    return _isScanning
        ? Center(child: CircularProgressIndicator())
        : _availableServers.isEmpty
            ? Center(child: Text('No servers found.'))
            : ListView.builder(
                itemCount: _availableServers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Server found at: ${_availableServers[index]}'),
                    onTap: () {
                      Showpopup(
                        context,
                        "username",
                        "password",
                        _availableServers[
                            index], //Burada showpopup fonksiyonu çağırılmıştır ve hangi servera girildiyse bulunan
                        // IP'lerin portları tam olarak o indexte olacağı için ona bağlanır."username" ve "password" sadece burada içine kullanıcı adı ve
                        //şifre girilen text bölgelerinin üstünde çıkan ismini göstermek içindir.
                        //(örneğin iki adet server bulduk index 1 olur ve ona bağlanır)
                      );
                    },
                  );
                },
              );
  }

  ElevatedButton getScanButton() {
    return ElevatedButton(
      onPressed: _isScanning ? null : _startScan,
      child: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
    );
  }

  TextField getNetworkField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      onSubmitted: (_) => _startScan(),
    );
  }

  void _startScan() {
    setState(() {
      _subnet = _subnetController.text == ""
          ? "192.168.0"
          : _subnetController
              .text; // Eğer subnetControllerın içi boş bırakılırsa bu değer girilir.
      MqttService.nick = _nickController.text == ""
          ? "noName"
          : _nickController.text; //Eğer nick boş bırakılırsa noName girilir.
      MqttService.userPort = _portController.text == ""
          ? "1883"
          : _portController.text; //Eğer port boş bırıkılırsa bu portu girer.
      _availableServers.clear();
      _isScanning = true;
    });

    final port = int.tryParse(_portController.text) ?? 1883;
    _scanNetwork(port);
  }

  Future<void> _scanNetwork(int port) async {
    List<Future<bool>> futures =
        pingIPs(port); //portların pinglenmesi ve futures içine yazılması
    List<String> servers = await addFoundIPs(
        futures); //bulunmuş Ip'leri liste içine sırayla yazar.
    setState(() {
      _availableServers = servers;
      _isScanning = false;
    });
  }

  Future<List<String>> addFoundIPs(List<Future<bool>> futures) async {
    //bulunan serverların eklenmesi
    final results = await Future.wait(futures);
    final servers = <String>[];

    for (int i = 0; i < results.length; i++) {
      if (results[i]) {
        //eğer resultsın herhangi bir indexi true olursa orada server var demektir.
        //tam olarak o sayının indexini subnetin noktadan sonraki uzantısı olarak yazarız.
        servers.add('$_subnet.${i + 1}');
      }
    }
    return servers; //bulunan serverı döndürür.
  }

  List<Future<bool>> pingIPs(int port) {
    //1 den 255 e kadar pinglenmesi
    final futures = <Future<bool>>[];

    return pingEachIP(futures, port);
  }

  List<Future<bool>> pingEachIP(List<Future<bool>> futures, int port) {
    for (int i = 1; i < 255; i++) {
      final ip = '$_subnet.$i';
      futures.add(_ping(ip, port));
    }
    return futures;
  }

  Future<bool> _ping(String ip, int port) async {
    try {
      final socket =
          await Socket.connect(ip, port, timeout: Duration(milliseconds: 500));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'network_scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Byte Bazaar',
            style: TextStyle(fontFamily: "NewAmsterdam", fontSize: 46),
          ),
          actions: [
            IconButton(
              icon: Icon(_isDarkTheme ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  _isDarkTheme = !_isDarkTheme;
                });
              },
            ),
          ],
        ),
        body: NetworkScanner(),
      ),
    );
  }
}

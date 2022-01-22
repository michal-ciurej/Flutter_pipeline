import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';

class Settings extends StatefulWidget {
  late StompClient client;

  Settings({required this.client});

  @override
  _Settings createState() => _Settings(client);
}

class _Settings extends State<Settings> {
  var client;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String company = 'bob';

  _Settings(this.client);

  Future<void> _getPreferences() async {
    final SharedPreferences prefs = await _prefs;
    final String storedcompany = (prefs.getString('company') ?? "Company Code");

    setState(() {
      company = storedcompany;
    });
  }

  Future<void> _savePreferences(String companyCode) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('company', companyCode);
  }

  @override
  void initState() {
    super.initState();
    _getPreferences();
  }

//https://pub.dev/packages/flutter_login
  @override
  Widget build(BuildContext context) {
    return Text("Settings");
  }
}

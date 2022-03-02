import 'dart:async';
import 'dart:convert';

import 'package:alerts/AlarmMessagePayload.dart';
import 'package:alerts/BarChart.dart';
import 'package:alerts/Gague.dart';
import 'package:alerts/LineChart.dart';
import 'package:alerts/WorkflowKanban.dart';
import 'package:alerts/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_handler.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'AppMessages.dart';
import 'Cases.dart';
import 'LoginScreen.dart';
import 'Site.dart';
import 'Ticket.dart';
import 'globals.dart' as globals;
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:http/http.dart' as http;

class AlertHistoryScreen extends StatefulWidget {
  final StompClient client;
  final String site;
  final String asset;

  const AlertHistoryScreen(
      {Key? key, required this.site, required this.asset ,required this.client})
      : super(key: key);

  @override
  _AlertHistoryScreen createState() => _AlertHistoryScreen(client, site, asset);

// CasesScreen(
//     {required this.update, required this.ticket, required this.client});

}

class _AlertHistoryScreen extends State<AlertHistoryScreen> {

  StompClient client;
  List<AlarmMessagePayload> history = [];

  String site;

  String asset;

  _AlertHistoryScreen(StompClient this.client, String this.site, String this.asset);

  @override
  void initState()  {

    getAlertHistory(site, asset).then((value)
      {
        var data= jsonDecode(value.body);
        setState(() {

            history.addAll(AlarmMessagePayload().fromJson(data));

        });
      });

       super.initState();


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF25b432),
          title: Text('Alert History'),
        ),
        body: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return Card(child: Text(history[index].name));
            }));
  }

  Future<http.Response> getAlertHistory(String site, String asset) async {
    final response = http.get(
      Uri.parse(protocol + '://' + serverAddress + port + '/api/alert/history/'+ site + "/"+ asset+ "/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }
    );
    return response;
  }
}

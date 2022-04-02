import 'dart:async';
import 'dart:convert';

import 'package:alerts/AlarmMessagePayload.dart';
import 'package:alerts/AlertsScreen.dart';
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
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'AppMessages.dart';
import 'AssetConsumer.dart';
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
      {Key? key, required this.site, required this.asset, required this.client})
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

  _AlertHistoryScreen(
      StompClient this.client, String this.site, String this.asset);

  @override
  void initState() {
    getAlertHistory(site, asset).then((value) {
      var data = jsonDecode(value.body);
      setState(() {
        history.addAll(AlarmMessagePayload().fromJson(data));
        history.sort((a, b) => DateFormat("HH:mm dd-MMM-yyyy")
            .parse(b.dateTime)
            .compareTo(DateFormat("HH:mm dd-MMM-yyyy").parse(a.dateTime)));
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Asset currentasset = assets.assets.firstWhere(
        (element) => (site == element.site && element.name == asset));

    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 150,
        title: Container(
          child: Container(
            // DefaultTextStyle: TextStyle(color: Colors.red),
            padding: EdgeInsets.only(top: 20),
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(0.3),
                1: FlexColumnWidth(0.7),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.top,
                      child: Container(
                        height: 25,
                        //width: 32,
                        color: Colors.transparent,
                        child: Text("Asset:",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                ?.copyWith(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary)
                            //GoogleFonts.roboto(
                            //    fontSize: 14,
                            //    fontWeight:
                            //    FontWeight.w200)
                            ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.top,
                      child: Container(
                        height: 25,
                        //  width: 32,
                        color: Colors.transparent,
                        child: Text(currentasset.name.toString(),
                            style: Theme.of(context).textTheme.headline6),
                      ),
                    )
                  ],
                ),
                TableRow(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  children: <Widget>[
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.top,
                      child: Container(
                          height: 20,
                          width: 32,
                          color: Colors.transparent,
                          child: Text("Asset Type",
                              style: Theme.of(context).textTheme.bodyText2)),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.top,
                      child: Container(
                        height: 20,
                        width: 32,
                        color: Colors.transparent,
                        child: Text(currentasset.type.toString(),
                            style: Theme.of(context).textTheme.subtitle2),
                      ),
                    )
                  ],
                ),
                if (currentasset.id != null) ...[
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    children: <Widget>[
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.top,
                        child: Container(
                            height: 20,
                            width: 32,
                            color: Colors.transparent,
                            child: Text("Sensor Id",
                                style: Theme.of(context).textTheme.bodyText2)),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.top,
                        child: Container(
                            height: 20,
                            width: 32,
                            color: Colors.transparent,
                            child: Text(currentasset.id.toString(),
                                style: Theme.of(context).textTheme.subtitle2)),
                      )
                    ],
                  )
                ],
                TableRow(
                  children: <Widget>[
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.top,
                      child: Container(
                        height: 20,
                        width: 32,
                        color: Colors.transparent,
                        child: Text("Manufacturer",
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.top,
                      child: Container(
                        height: 20,
                        width: 32,
                        color: Colors.transparent,
                        child: Text(currentasset.manufacturer.toString(),
                            style: Theme.of(context).textTheme.subtitle2),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
      ),
      body: ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            return Neumorphic(
              margin: EdgeInsets.fromLTRB(25, 5, 25, 0),
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                border: NeumorphicBorder(color: Color(0x33000000), width: 0.8),
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                depth: 1,
                lightSource: LightSource.topLeft,
                color: Colors.white,
              ),
              child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    Text(
                        history[index].dateTime,
                        style: Theme.of(context).textTheme.subtitle2),
                    Text(" - " + history[index].name,
                        style: Theme.of(context).textTheme.subtitle2)
                  ])),
            );
          }),

      // if (history.isEmpty) ...[

      //]
      // ]
    );
  }

  Future<http.Response> getAlertHistory(String site, String asset) async {
    final response = http.get(
        Uri.parse(protocol +
            '://' +
            serverAddress +
            port +
            '/api/alert/history/' +
            site +
            "/" +
            asset +
            "/"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
    return response;
  }
}

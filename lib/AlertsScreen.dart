import 'dart:convert';
import 'dart:typed_data';

import 'package:alerts/BarChart.dart';
import 'package:alerts/Gague.dart';
import 'package:alerts/LineChart.dart';
import 'package:alerts/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';

import 'AlarmMessagePayload.dart';
import 'AppMessages.dart';
import 'AssetConsumer.dart';
import 'Site.dart';
import 'Ticket.dart';
import 'globals.dart' as globals;

class AlertsScreen extends StatefulWidget {
  final ValueChanged<String> update;
  final ValueChanged<int> ticket;

  StompClient client;

  AlertsScreen(
      {required this.update, required this.ticket, required this.client});

  @override
  _AlertsScreen createState() => _AlertsScreen(client, update);
}

class _AlertsScreen extends State<AlertsScreen> {
  StompClient client;
  var isFilterSwitched = false;
  ValueChanged<String> update;

  _AlertsScreen(StompClient this.client, ValueChanged<String> this.update);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppMessages>(builder: (context, data, _) {
      return Column(children: [
        Row(children: [
          if (MediaQuery.of(context).size.width > 10000) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Tickets",
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
            )
          ],
          // Here, default theme colors are used for activeBgColor, activeFgColor, inactiveBgColor and inactiveFgColor
          Container(
              child: Expanded(
                  child: SwitchListTile(
            title: const Text('Un-Cleared Alerts'),
            value: isFilterSwitched,
            onChanged: (bool value) {
              setState(() {
                isFilterSwitched = value;
              });
            },
            secondary: const Icon(Icons.warning_amber),
          ))),
        ]),
        Container(child: Expanded(child: Consumer<AppMessages>(
          builder: (context, data, _) {
            var enabledSites = Provider.of<Sites>(context)
                .sites
                .where((element) => element.checked == true)
                .toList();

            var enabledTypes = Provider.of<Assets>(context)
                .assetClasses
                .where((element) => element.checked == true)
                .toList();

            //filter out any alerts where the site is not monitored
            var messages = data.entries
                .where((element) => enabledSites
                    .where((site) =>
                        site.name == element.site &&
                        (element.status == 'Active' ||
                            element.ack
                                    .toString()
                                    .toUpperCase()
                                    .compareTo("FALSE") ==
                                0))
                    .isNotEmpty)
                .toList();

            //filter out any alers where the type is not monitored
            messages = messages
                .where((element) => enabledTypes
                    .where((type) => type.assetClass == element.assetClass)
                    .isNotEmpty)
                .toList();

            if (isFilterSwitched) {
              messages = messages
                  .where((element) => element.status != 'Inactive')
                  .toList();
            }

            bool _customTileExpanded = false;

            return GroupedListView<AlarmMessagePayload, String>(
              elements: messages,
              groupBy: (element) => element.site,
              groupComparator: (value1, value2) => value2.compareTo(value1),
              itemComparator: (item1, item2) =>
                  int.parse(item1.priority)
                      .compareTo(int.parse(item2.priority)) *
                  -1,
              order: GroupedListOrder.DESC,
              useStickyGroupSeparators: true,
              groupSeparatorBuilder: (String value) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                          height: 30,
                          child: Image.network(protocol +
                              '://' +
                              serverAddress +
                               port + '/api/static/' +
                              sites.sites
                                  .firstWhere(
                                      (element) => element.name == value)
                                  .imageName)),
                      Text(
                        value,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.normal),
                      )
                    ],
                  )),
              itemBuilder: (index, message) {
                return Card(
                  elevation: 2,
                  child: ClipPath(
                    child: Container(
                      child: Slidable(

                          // Specify a key if the Slidable is dismissible.
                          key: const ValueKey(0),

                          // The start action pane is the one at the left or the top side.

                          startActionPane: message.ack
                                      .toString()
                                      .toUpperCase()
                                      .compareTo("TRUE") ==
                                  0
                              ? null
                              : ActionPane(
                                  //extentRatio:0.0,
                                  // A motion is a widget used to control how the pane animates.
                                  motion: const ScrollMotion(),
                                  extentRatio: 0.25,
                                  // A pane can dismiss the Slidable.
                                  //dismissible: DismissiblePane(onDismissed: () {}),

                                  // All actions are defined in the children parameter.
                                  children: [
                                    // A SlidableAction can have an icon and/or a label.

                                    /*if (message.ack
                                      .toString()
                                      .toUpperCase()
                                      .compareTo("TRUE") ==
                                  0) ...[
                                SlidableAction(
                                  onPressed: (BuildContext context) =>
                                      {update(message.id)},
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Dismiss',
                                )
                              ],*/
                                    if (message.ack
                                            .toString()
                                            .toUpperCase()
                                            .compareTo("FALSE") ==
                                        0) ...[
                                      SlidableAction(
                                        onPressed: (BuildContext context) =>
                                            {update(message.id)},
                                        backgroundColor: Color(0xFF21B7CA),
                                        foregroundColor: Colors.white,
                                        icon: Icons.check,
                                        label: 'Acknowledge',
                                      )
                                    ],
                                  ],
                                ),

                          // The end action pane is the one at the right or the bottom side.

                          endActionPane: userDetails.featureToggles
                                      .contains("tickets") ==
                                  false
                              ? null
                              : ActionPane(
                                  motion: ScrollMotion(),
                                  extentRatio: 0.30,
                                  children: [
                                    SlidableAction(
                                      // An action can be bigger than the others.
                                      flex: 2,
                                      onPressed: (BuildContext context) => {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                FullScreenDialog(
                                                    id: message.id,
                                                    stompClient: client),
                                            fullscreenDialog: true,
                                          ),
                                        )
                                      },
                                      backgroundColor: Color(0xFF7BC043),
                                      foregroundColor: Colors.white,
                                      icon: Icons.archive,
                                      label: 'Raise Ticket',
                                    )
                                  ],
                                ),

                          // The child of the Slidable is what the user sees when the
                          // component is not dragged.
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(1.0),
                            child: Column(
                              children: <Widget>[
                                ExpansionTile(
                                  onExpansionChanged: (bool expanding) =>
                                      _onExpansion(expanding, message.id),

                                  //backgroundColor: Colors.white,
                                  trailing: Icon(
                                    _customTileExpanded
                                        ? Icons.arrow_drop_down_circle
                                        : Icons.arrow_drop_down,
                                  ),
                                  leading: Icon(Icons.thermostat,
                                      size: 50.0,
                                      color: message.type == 'underTemperature'
                                          ? Colors.blue
                                          : Colors.deepOrange),
                                  title: Text("P" +
                                      message.priority +
                                      " - " +
                                      message.type),
                                  subtitle: Text(message.name),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  children: <Widget>[
                                    ListTile(
                                        title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                          Column(children: [
                                            Text("Acknowledged "),
                                            Icon(
                                              message.ack == "true"
                                                  ? Icons.verified
                                                  : Icons.clear,
                                            )
                                          ]),
                                          Column(children: [
                                            Text("Alert Status "),
                                            Icon(
                                              message.status == "Active"
                                                  ? Icons.notifications_active
                                                  : Icons.notifications_off,
                                            ),
                                          ]),
                                          Column(children: [
                                            Text("Open Tickets"),
                                            Icon(
                                              Icons.confirmation_number,
                                            ),
                                          ])
                                        ])),
                                    ListTile(
                                        title: Table(
                                            columnWidths: const <int,
                                                TableColumnWidth>{
                                              0: FlexColumnWidth(0.1),
                                              1: FlexColumnWidth(0.3),
                                            },
                                            defaultVerticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            children: <TableRow>[
                                              TableRow(
                                                children: <Widget>[
                                                  TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .top,
                                                    child: Container(
                                                      height: 32,
                                                      width: 32,
                                                      color: Colors.transparent,
                                                      child:
                                                          Text("Asset Class"),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .top,
                                                    child: Container(
                                                      height: 32,
                                                      width: 32,
                                                      color: Colors.transparent,
                                                      child: Text(
                                                          message.assetClass),
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
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .top,
                                                    child: Container(
                                                        height: 32,
                                                        width: 32,
                                                        color:
                                                            Colors.transparent,
                                                        child:
                                                            Text("Asset Type")),
                                                  ),
                                                  TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .top,
                                                    child: Container(
                                                        height: 32,
                                                        width: 32,
                                                        color:
                                                            Colors.transparent,
                                                        child: Text(
                                                            message.assetType)),
                                                  )
                                                ],
                                              ),
                                              TableRow(
                                                children: <Widget>[
                                                  TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .top,
                                                    child: Container(
                                                      height: 32,
                                                      width: 32,
                                                      color: Colors.transparent,
                                                      child: Text("Asset Name"),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .top,
                                                    child: Container(
                                                      height: 32,
                                                      width: 32,
                                                      color: Colors.transparent,
                                                      child:
                                                          Text(message.asset),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              TableRow(
                                                children: <Widget>[
                                                  TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .top,
                                                    child: Container(
                                                      height: 32,
                                                      width: 32,
                                                      color: Colors.transparent,
                                                      child:
                                                          Text("Manufacturer"),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .top,
                                                    child: Container(
                                                      height: 32,
                                                      width: 32,
                                                      color: Colors.transparent,
                                                      child: Text(assets.assets
                                                          .where((element) => (element
                                                                      .site ==
                                                                  message
                                                                      .site &&
                                                              element.type ==
                                                                  message
                                                                      .assetType))
                                                          .toList()
                                                          .map((e) =>
                                                              e.manufacturer)
                                                          .toString()),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ])),



                                    /*ListTile(
                                        title: Text(
                                            "Asset Class: " + message.assetClass),
                                    subtitle: Text(
                                        "Asset Name: " + message.asset),
                                    ),

                                    ListTile(
                                        title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                          Text("Ticket: "),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.confirmation_number,
                                                size: 35),
                                            tooltip: message.caseNumber,
                                            onPressed: () {},
                                          )
                                        ])),
                                    ListTile(
                                        title: Row(children: [
                                      Text("Status: "),
                                      Icon(
                                        message.status == "Active"
                                            ? Icons.notifications_active
                                            : Icons.notifications_off,
                                      )
                                    ])),
                                    if (userDetails.featureToggles
                                        .contains("charts")) ...[
                                      ListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            ElevatedButton(
                                                child: Text('Telemetry'),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          LineChart(
                                                              client: client),
                                                    ),
                                                  );
                                                }),
                                            ElevatedButton(
                                                child: Text('Points Feed'),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Gague(client: client),
                                                    ),
                                                  );
                                                }),
                                            ElevatedButton(
                                                child: Text('Alarm History'),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BarChart(
                                                              client: client),
                                                    ),
                                                  );
                                                })
                                          ],
                                        ),
                                      )
                                    ]
                                  */
                                  ],
                                ),
                              ],
                            ),
                          )),
                      //height: 100,
                      decoration: BoxDecoration(
                          color: message.status == 'Inactive'
                              ? Colors.greenAccent
                              : Colors.white,
                          border: Border(
                              right: BorderSide(
                                  color: message.type == 'underTemperature'
                                      ? Colors.blue
                                      : Colors.deepOrange,
                                  width: 5),
                              left: BorderSide(
                                  color: message.type == 'underTemperature'
                                      ? Colors.blue
                                      : Colors.deepOrange,
                                  width: 5))),
                    ),
                    clipper: ShapeBorderClipper(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3))),
                  ),
                );
              },
            );
          },
        )))
      ]);
    });
  }

  void _onExpansion(bool value, String id) {
    if (value == true) {
      cases.setFilter(id);
    } else {
      cases.setFilter('none');
    }
  }
}

void doNothing(BuildContext context) {
  globals.currentIndex = 2;
}

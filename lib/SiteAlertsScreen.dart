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

import 'AlertHistoryScreen.dart';
import 'AppMessages.dart';
import 'AssetConsumer.dart';
import 'Cases.dart';
import 'LoginScreen.dart';
import 'Site.dart';
import 'Ticket.dart';
import 'globals.dart' as globals;
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:http/http.dart' as http;

class SiteAlertsScreen extends StatefulWidget {
  final StompClient client;
  final List<AlarmMessagePayload> siteSpecificMessages;
  final String site;

  final ValueChanged<String> update;

  var isFilterSwitched;

   SiteAlertsScreen(
      {Key? key,
      required this.site,
      required this.siteSpecificMessages,
      required this.client,
      required this.update,
      required this.isFilterSwitched
      })
      : super(key: key);

  @override
  _SiteAlertsScreen createState() =>
      _SiteAlertsScreen(client, site, siteSpecificMessages, update, isFilterSwitched);
}

class _SiteAlertsScreen extends State<SiteAlertsScreen> {
  StompClient client;
  List<AlarmMessagePayload> siteSpecificMessages;
  String site;
  ValueChanged<String> update;
  var isFilterSwitched;

  _SiteAlertsScreen(StompClient this.client, String this.site,
      List<AlarmMessagePayload> this.siteSpecificMessages, this.update, this.isFilterSwitched);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          toolbarHeight: 80,
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
                          child: Text("Site:",
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
                          child: Text(site,
                              style: Theme.of(context).textTheme.headline6),
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
        body: Consumer<AppMessages>(builder: (context, data, _) {



          siteSpecificMessages.clear();
          siteSpecificMessages = Provider.of<AppMessages>(context).entries
              .where((element) =>
          element.site ==
              site)
              .toList();

          if (isFilterSwitched) {
            siteSpecificMessages = siteSpecificMessages
                .where((element) => element.status != 'Inactive')
                .toList();
          }


          return ListView.builder(
              shrinkWrap: true,
              itemCount: siteSpecificMessages.length,
              itemBuilder: (context, index) {
                var element = siteSpecificMessages[index];
                return Neumorphic(
                    // padding:EdgeInsets.fromLTRB(20, 5, 20, 5),
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12)),
                        depth: 3,
                        lightSource: LightSource.topLeft,
                        color: Colors.white,
                        border: NeumorphicBorder(
                          color: (element.status == 'Active' &&
                                  element.ack
                                          .toString()
                                          .toUpperCase()
                                          .compareTo("FALSE") ==
                                      0)
                              ? Colors.red
                              : (element.status == 'Active' &&
                                      element.ack
                                              .toString()
                                              .toUpperCase()
                                              .compareTo("FALSE") !=
                                          0)
                                  ? Color(0xffa3a3a3)
                                  : Colors.green,
                          width: 2,
                        )),

                    // decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     border: Border(
                    //         right: BorderSide(color: element.status=='Active' ? Colors.red: Colors.lightGreen, width: 5),
                    //         left: BorderSide(
                    //
                    //
                    //
                    //
                    //             color: element.status=='Active' ? Colors.red: Colors.lightGreen, width: 5))),
                    child: Slidable(
                        // Specify a key if the Slidable is dismissible.
                        key: ValueKey(siteSpecificMessages.indexOf(element)),

                        // The start action pane is the one at the left or the top side.
                        startActionPane: ActionPane(
                          // A motion is a widget used to control how the pane animates.
                          motion: const ScrollMotion(),
                          //check here

                          // A pane can dismiss the Slidable.
                          //  dismissible: DismissiblePane(
                          //    onDismissed: () {}),

                          // All actions are defined in the children parameter.

                          children: [
                            // A SlidableAction can have an icon and/or a label.
                            if (element.ack == 'false') ...[
                              SlidableAction(
                                onPressed: (BuildContext context) =>
                                    {update(element.id)},
                                backgroundColor: Color(0xff595959),
                                foregroundColor: Colors.white,
                                icon: Icons.task_alt_outlined,
                                label: 'Acknowledge',
                              )
                            ] else ...[
                              SlidableAction(
                                onPressed: (BuildContext context) => {},
                                backgroundColor: Color(0xff595959),
                                foregroundColor: Colors.white,
                                icon: Icons.close_outlined,
                                label: 'Acknowledged',
                              )
                            ]
                          ],
                        ),

                        // The end action pane is the one at the right or the bottom side.
                        endActionPane:
                            !userDetails.featureToggles.contains("ticket")
                                ? null
                                : const ActionPane(
                                    motion: ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        // An action can be bigger than the others.
                                        flex: 2,
                                        onPressed: doNothing,
                                        backgroundColor: Color(0xFF7BC043),
                                        foregroundColor: Colors.white,
                                        icon: Icons.archive,
                                        label: 'Archive',
                                      ),
                                    ],
                                  ),

                        // The child of the Slidable is what the user sees when the
                        // component is not dragged.
                        // Site Container Clapham
                        child: ExpansionTile(
                            tilePadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            //margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            //  tilePadding: EdgeInsets.zero,
                            //  childrenPadding: EdgeInsets.zero,
                            onExpansionChanged: (value) => {
                                  setState(() {
                                    //site.expanded = value;
                                  })
                                },
                            title: Row(children: [
                              Icon(
                                Icons.notifications,
                                color: (element.status == 'Active' &&
                                        element.ack
                                                .toString()
                                                .toUpperCase()
                                                .compareTo("FALSE") ==
                                            0)
                                    ? Colors.red
                                    : (element.status == 'Active' &&
                                            element.ack
                                                    .toString()
                                                    .toUpperCase()
                                                    .compareTo("FALSE") !=
                                                0)
                                        ? Color(0xff595959)
                                        : Colors.green,
                                size: 35.0,
                              ),
                              Text(
                                "  " + element.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    ?.copyWith(fontSize: 19),
                              )
                            ]),
                            subtitle: Text(element.dateTime,
                                style: GoogleFonts.roboto(
                                    fontSize: 13, fontWeight: FontWeight.w300)),
                            children: [
                              ListTile(
                                title: Table(
                                  columnWidths: const <int, TableColumnWidth>{
                                    0: FlexColumnWidth(0.3),
                                    1: FlexColumnWidth(0.7),
                                  },
                                  defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  children: <TableRow>[
                                    TableRow(
                                      children: <Widget>[
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.top,
                                          child: Container(
                                            height: 25,
                                            width: 32,
                                            color: Colors.transparent,
                                            child: Text("Asset Class",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2
                                                //GoogleFonts.roboto(
                                                //    fontSize: 14,
                                                //    fontWeight:
                                                //    FontWeight.w200)
                                                ),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.top,
                                          child: Container(
                                            height: 25,
                                            width: 32,
                                            color: Colors.transparent,
                                            child: Text(element.assetClass,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2),
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
                                              TableCellVerticalAlignment.top,
                                          child: Container(
                                              height: 25,
                                              width: 32,
                                              color: Colors.transparent,
                                              child: Text("Asset Type:",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2)),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.top,
                                          child: Container(
                                              height: 25,
                                              width: 32,
                                              color: Colors.transparent,
                                              child: Text(element.assetType,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2)),
                                        )
                                      ],
                                    ),
                                    TableRow(
                                      children: <Widget>[
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.top,
                                          child: Container(
                                            height: 25,
                                            width: 32,
                                            color: Colors.transparent,
                                            child: Text("Asset Name",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.top,
                                          child: Container(
                                            height: 25,
                                            width: 32,
                                            color: Colors.transparent,
                                            child: Text(element.asset,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2),
                                          ),
                                        )
                                      ],
                                    ),
                                    if (element.sensorId != null) ...[
                                      TableRow(
                                        decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        children: <Widget>[
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment.top,
                                            child: Container(
                                                height: 25,
                                                width: 32,
                                                color: Colors.transparent,
                                                child: Text("Sensor Id:",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2)),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment.top,
                                            child: Container(
                                                height: 25,
                                                width: 32,
                                                color: Colors.transparent,
                                                child: Text(element.sensorId,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2)),
                                          )
                                        ],
                                      )
                                    ],
                                    if (element.messageText != null) ...[
                                      TableRow(
                                        decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        children: <Widget>[
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment.top,
                                            child: Container(
                                                height: 25,
                                                width: 32,
                                                color: Colors.transparent,
                                                child: Text("Alert Description",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2)),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment.top,
                                            child: Container(
                                                height: 25,
                                                width: 32,
                                                color: Colors.transparent,
                                                child: Text(element.messageText,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2)),
                                          )
                                        ],
                                      )
                                    ],
                                    TableRow(
                                      children: <Widget>[
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.top,
                                          child: Container(
                                            height: 25,
                                            width: 32,
                                            color: Colors.transparent,
                                            child: Text("Manufacturer:",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.top,
                                          child: Container(
                                            height: 25,
                                            width: 32,
                                            color: Colors.transparent,
                                            child: Text(
                                                assets.assets
                                                    .where((asset) =>
                                                        (element.site ==
                                                                asset.site &&
                                                            asset.name ==
                                                                element.asset))
                                                    .toList()
                                                    .map((e) => e.manufacturer)
                                                    .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2),
                                          ),
                                        )
                                      ],
                                    ),
                                    TableRow(
                                      children: <Widget>[
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.top,
                                          child: Container(
                                            height: 25,
                                            width: 32,
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.top,
                                          child: Container(
                                            width: 1,
                                            margin: EdgeInsets.only(bottom: 10),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                /*  margin: EdgeInsets.only(bottom: 10),
                                                alignment: Alignment.centerRight,
                                                height: 25,
                                               // width: 32,
                                                color: Colors.transparent, */
                                                children: [
                                                  Text("Alarm History: ",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black26)),
                                                  IconButton(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    icon: Icon(
                                                      Icons.history_outlined,
                                                      color: Colors.black26,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute<void>(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              AlertHistoryScreen(
                                                                  site: element
                                                                      .site,
                                                                  asset: element
                                                                      .asset,
                                                                  client:
                                                                      client),
                                                          //  fullscreenDialog: true,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ]),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ])));
              });
        }));
  }
}

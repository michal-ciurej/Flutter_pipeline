import 'package:accordion/accordion.dart';
import 'package:alerts/main.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:intl/intl.dart';
import 'AlarmMessagePayload.dart';
import 'AlertHistoryScreen.dart';
import 'AppMessages.dart';
import 'AssetConsumer.dart';
import 'Site.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
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
          title: const Text('Hide Cleared Alerts'),
          value: isFilterSwitched,
          onChanged: (bool value) {
            setState(() {
              isFilterSwitched = value;
            });
          },
          secondary: const Icon(Icons.warning_amber),
        ))),
      ]),
      Container(
          //   decoration: BoxDecoration(),

          child: Expanded(child: Consumer<AppMessages>(
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
                      //logic deciding when a site is alarmed but acknowledged... I think
                      site.name == element.site &&
                      (element.status == 'Active' ||
                          element.ack
                                  .toString()
                                  .toUpperCase()
                                  .compareTo("FALSE") ==
                              0))
                  .isNotEmpty)
              .toList();

          // messages.where((Clapham) => true).length.toString()

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

          void _doNothing(BuildContext context) {}

          Widget _getMessages(String site, List<AlarmMessagePayload> messages) {
            print("getting messages ...");
            var elements =
                messages.where((message) => message.site == site).toList();
            //var currentTime = messages.DateTime;
            //DateFormat.jm().format(DateTime.now());

            ScrollController scrollController = ScrollController(
              initialScrollOffset: 10, // or whatever offset you wish
              keepScrollOffset: true,
            );

            return ListView.builder(
                shrinkWrap: true,
                controller: scrollController,
                itemCount: elements.length,
                itemBuilder: (context, index) {
                  var element = elements[index];
                  print("returning a message ..." + element.id);
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
                          key: ValueKey(messages.indexOf(element)),

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
                              subtitle: Text(DateFormat("HH:mm dd-MMM-yyyy")
                                  .format(DateTime.parse(element.dateTime))),
                              children: [
                                ListTile(
                                  title: Table(
                                    columnWidths: const <int, TableColumnWidth>{
                                      0: FlexColumnWidth(0.2),
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
                                                      .bodyText2
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
                                                      .subtitle2),
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
                                                child: Text("Asset Type",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2)),
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
                                                        .subtitle2)),
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
                                                      .bodyText2),
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
                                                      .subtitle2),
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
                                                  TableCellVerticalAlignment
                                                      .top,
                                              child: Container(
                                                  height: 25,
                                                  width: 32,
                                                  color: Colors.transparent,
                                                  child: Text("Sensor Id",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2)),
                                            ),
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .top,
                                              child: Container(
                                                  height: 25,
                                                  width: 32,
                                                  color: Colors.transparent,
                                                  child: Text(element.sensorId,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2)),
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
                                              TableCellVerticalAlignment
                                                  .top,
                                              child: Container(
                                                  height: 25,
                                                  width: 32,
                                                  color: Colors.transparent,
                                                  child: Text("Alert Description",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2)),
                                            ),
                                            TableCell(
                                              verticalAlignment:
                                              TableCellVerticalAlignment
                                                  .top,
                                              child: Container(
                                                  height: 25,
                                                  width: 32,
                                                  color: Colors.transparent,
                                                  child: Text(element.messageText,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2)),
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
                                              child: Text("Manufacturer",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2),
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
                                                      .where((asset) => (element
                                                                  .site ==
                                                              asset.site &&
                                                          asset.name ==
                                                              element.asset))
                                                      .toList()
                                                      .map(
                                                          (e) => e.manufacturer)
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2),
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
                                                mainAxisAlignment: MainAxisAlignment.end,
                                              /*  margin: EdgeInsets.only(bottom: 10),
                                                alignment: Alignment.centerRight,
                                                height: 25,
                                               // width: 32,
                                                color: Colors.transparent, */
                                                children: [
                                                  Text("Alarm History: ",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2!.copyWith(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black26)),

                                                IconButton(
                                                  alignment: Alignment.centerRight,
                                                  icon: Icon(Icons.history_outlined, color: Colors.black26,),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute<void>(
                                                        builder: (BuildContext context) => AlertHistoryScreen(
                                                            site: element.site,
                                                            asset: element.asset,
                                                            client: client),
                                                      //  fullscreenDialog: true,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ]
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ])));
                });
          }

          Widget _getSites(
              List<Site> enabledSites, List<AlarmMessagePayload> messages) {
            print("getting the sites....");

            return ListView.builder(
                shrinkWrap: true,
                itemCount: enabledSites.length,
                itemBuilder: (context, index) {
                  var site = enabledSites[index];

                  // Site container background clapham
                  print("adding a site to the list...");

                  //Container for each site being added
                  return Neumorphic(
                      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      padding: EdgeInsets.all(10),
                      style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          border: NeumorphicBorder(
                            color: messages
                                    .where((message) =>
                                        message.site == site.name &&
                                        message.status == 'Active')
                                    .toList()
                                    .isEmpty
                                ? Colors.transparent
                                : Colors.red.withOpacity(0.3),
                            width: site.expanded == false ? 1 : 0,
                          ),
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(12)),
                          depth: site.expanded == false ? 3 : 5,
                          lightSource: LightSource.topLeft,
                          color: site.expanded == false
                              ? Colors.white
                              : Colors.white

                          //padding: const EdgeInsets.all(0.0),
                          // decoration: BoxDecoration(

                          //color: site.expanded==false ? Colors.white :  Colors.white,
                          //  border: Border(
                          //      right: BorderSide(color: site.expanded==false ? Colors.red: Colors.transparent, width: 5),
                          //    left: BorderSide(color: site.expanded==false ? Colors.red: Colors.transparent, width: 5))

                          ),
                      child: Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            childrenPadding: EdgeInsets.zero,
                            onExpansionChanged: (value) => {
                              setState(() {
                                site.expanded = value;
                              })
                            },
                            //messages.where((site) => site.name).length.toString()
                            title: Text(
                              site.name,
                              style: GoogleFonts.roboto(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(children: [
                              Text(
                                messages
                                        .where((message) =>
                                            message.site == site.name &&
                                            message.status == 'Active')
                                        .toList()
                                        .length
                                        .toString() +
                                    " Active"

                                //data.entries.where(() => site.name) + " alarms"
                                ,
                                style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "  " +
                                    messages
                                        .where((message) =>
                                            message.site == site.name &&
                                            message.status == 'Inactive')
                                        .toList()
                                        .length
                                        .toString() +
                                    " inactive"

                                //data.entries.where(() => site.name) + " alarms"
                                ,
                                style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w300),
                                //TextStyle(color: Colors.red, fontSize: 16, ),
                                //Theme.of(context).textTheme.bodyText2,
                              )
                            ]),

                            children: [
                              Container(
                                  child: _getMessages(site.name, messages))
                            ],
                          )));
                });
          }

          return _getSites(enabledSites, messages);
        },
      )))
    ]);
  }

  void _onExpansion(bool value, String id) {
    if (value == true) {
      cases.setFilter(id);
    } else {
      cases.setFilter('none');
    }
  }
}

void doNothing(BuildContext context) {}

import 'package:accordion/accordion.dart';
import 'package:alerts/SiteAlertsScreen.dart';
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
          var messages = Provider.of<AppMessages>(context).entries
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



          Widget _getSites(
              List<Site> enabledSites, List<AlarmMessagePayload> siteMessages, isFilterSwitched) {
            print("getting the sites....");

            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio: 1.8),

                shrinkWrap: true,
                clipBehavior: Clip.hardEdge,
                itemCount: enabledSites.length,
                itemBuilder: (context, index) {
                  var site = enabledSites[index];

                  //Container for each site being added
                  return GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute<
                              void>(
                            builder: (BuildContext
                            context) =>
                                SiteAlertsScreen(
                                    site: site.name,
                                    siteSpecificMessages: siteMessages
                                        .where((element) =>
                                    element.site ==
                                        site.name)
                                        .toList(),
                                    client:
                                    client,
                                    update:update,
                                    isFilterSwitched:isFilterSwitched),
                            //  fullscreenDialog: true,
                          ),
                        );
                  },
                  child:
                  Center(
                    child: Neumorphic(
                        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        padding: EdgeInsets.all(10),
                        style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            border: NeumorphicBorder(
                              color: siteMessages
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
                            ),
                        child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child:
                              Container(
                              height: 100,
                              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              //messages.where((site) => site.name).length.toString()
                              child: Column(
                                  children:[
                              Row(children:[
                                   Text(

                                site.name.toString().substring(0, 5), // I know it's not the right way but it's quick, TODO: actually pull the site ID
                                     style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    fontWeight:  FontWeight.w300
                                        ),
                              )]),
                                    Row(children:[
                                      Text(

                                        site.name.toString().substring(7,), // TODO:
                                        style: GoogleFonts.roboto(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      )]),
                               Row(

                                   children: [
                                Text(
                                  siteMessages
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
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  "  " +
                                      siteMessages
                                          .where((message) =>
                                              message.site == site.name &&
                                              message.status == 'Inactive')
                                          .toList()
                                          .length
                                          .toString() +
                                      " Inactive"

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


                            ]))


                        )),
                  ));
                });
          }

          return _getSites(enabledSites, messages, isFilterSwitched);
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

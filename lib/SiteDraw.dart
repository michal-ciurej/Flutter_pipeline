import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';

import 'AssetConsumer.dart';
import 'Site.dart';
import 'main.dart';

var autoPurge = false;


class SiteDraw extends StatefulWidget {


  @override
  _SiteDraw createState() => _SiteDraw();
}

class _SiteDraw extends State<SiteDraw> {
  List<Site> filteredSites = [];
  List<AssetClass> filteredAssetClasses = [];

  String searchString = "";
  var isFilterSwitched = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      filteredSites.addAll(Provider
          .of<Sites>(context, listen: false)
          .sites);

      filteredAssetClasses
          .addAll(Provider
          .of<Assets>(context, listen: false)
          .assetClasses);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController editingController = TextEditingController();

    //filteredSites.clear();

    return Drawer(

// Add a ListView to the drawer. This ensures the user can scroll
// through the options in the drawer if there isn't enough vertical
// space to fit everything.
        child: SizedBox(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: 50,
                      child: SizedBox(
                          child: SwitchListTile(
                            title: const Text('Assets Classes / Sites'),
                            value: isFilterSwitched,
                            onChanged: (bool value) {
                              setState(() {
                                isFilterSwitched = value;
                              });
                            },
                          ))),
                  Container(
                      height: 50,
                      child: SizedBox(
                          child: SwitchListTile(
                            title: const Text('Auto-remove cleared & acked'),
                            value: autoPurge,
                            onChanged: (bool value) {
                              setState(() {
                                autoPurge = value;
                              });
                            },
                          ))),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchString = value.toLowerCase();

                          filteredSites.clear();
                          filteredSites.addAll(
                              Provider
                                  .of<Sites>(context, listen: false)
                                  .sites
                                  .where((element) =>
                                  element.name
                                      .toString()
                                      .toLowerCase()
                                      .contains(searchString))
                                  .toList());

                          print(searchString);
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Search',
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: DrawerHeader(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              isFilterSwitched
                                  ? 'Available Sites'
                                  : 'Available Assets Classes',
                            ),
                          ],
                        ),
                      )),
                  if (isFilterSwitched) ...[
                    Expanded(
                      child: Consumer<Sites>(builder: (context, data, index) {
                        if (searchString.length > 0) {
                          filteredSites.clear();

                          print("filter bing used");
                          filteredSites.addAll(data.sites
                              .where((element) =>
                              element.name
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchString))
                              .toList());
                        } else {
                          print("No filter bing used");
                          filteredSites.clear();
                          filteredSites.addAll(data.sites);
                        }
                        return ListView.builder(
                            itemCount: filteredSites.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (filteredSites.length == 0) {
                                return CircularProgressIndicator(
                                  value: null,
                                  semanticsLabel: 'Linear progress indicator',
                                );
                              } else {
                                return CheckboxListTile(
                                    value: filteredSites[index].checked,
                                    onChanged: (value) {
                                      setState(() {
                                        Provider.of<Sites>(
                                            context, listen: false)
                                            .update(
                                            Provider
                                                .of<Sites>(context,
                                                listen: false)
                                                .sites
                                                .indexWhere((element) =>
                                            element.name ==
                                                filteredSites[index].name),
                                            value);
                                      });
                                    },
                                    title: Text(filteredSites[index].name),
                                    secondary: Container(
                                        height: 30,
                                        child: Image.network(protocol +
                                            '://' +
                                            serverAddress +
                                            ':8080/api/static/' +
                                            filteredSites
                                                .firstWhere((element) =>
                                            element.name ==
                                                filteredSites[index].name)
                                                .imageName)));
                              }
                            });
                      }),
                    )
                  ],
                  if (!isFilterSwitched) ...[
                    Expanded(
                      child: Consumer<Assets>(builder: (context, data, index) {
                        if (searchString.length > 0) {
                          filteredAssetClasses.clear();

                          print("filter bing used");
                          filteredAssetClasses.addAll(data.assetClasses
                              .where((element) =>
                              element.assetClass
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchString))
                              .toSet());
                        } else {
                          print("No filter bing used");
                          filteredAssetClasses.clear();
                          filteredAssetClasses.addAll(data.assetClasses);
                        }
                        return ListView.builder(
                            itemCount: filteredAssetClasses.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (filteredAssetClasses.length == 0) {
                                return CircularProgressIndicator(
                                  value: null,
                                  semanticsLabel: 'Linear progress indicator',
                                );
                              } else {
                                return CheckboxListTile(
                                    value: filteredAssetClasses[index].checked,
                                    onChanged: (value) {
                                      setState(() {
                                        Provider.of<Assets>(
                                            context, listen: false)
                                            .updateAssetClass(index, value);
                                      });
                                    },
                                    title: Text(
                                        filteredAssetClasses[index].assetClass),
                                    secondary: Container(
                                        height: 30,
                                        child: Image.network(protocol +
                                            '://' +
                                            serverAddress +
                                            ':8080/api/static/' +
                                            filteredAssetClasses
                                                .firstWhere((element) =>
                                            element.assetClass ==
                                                filteredAssetClasses[index]
                                                    .assetClass)
                                                .imageName)));
                              }
                            });
                      }),
                    )
                  ]
                ])));
  }
}

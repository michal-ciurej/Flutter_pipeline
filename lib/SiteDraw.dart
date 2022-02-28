import 'dart:convert';

import 'package:alerts/Theme/custom_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
//import 'package:sliding_switch/sliding_switch.dart';

import 'AssetConsumer.dart';
import 'Site.dart';
import 'main.dart';
import 'switch.dart';

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
  var selectAll = true;

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
                margin: EdgeInsets.fromLTRB(0, 15, 0, 3),
                child: SizedBox(
                  //asset class site switcher

                  //  child: SwitchListTile(
                  //      title: const Text('Assets Classes / Sites'),
                  //        value: isFilterSwitched,
                  //         onChanged: (bool value) {
                  //          setState(() {
                  //        isFilterSwitched = value;
                  //        });
                  //        },

                    child: SlidingSwitch(

                      value: isFilterSwitched,
                      width: 250,
                      onChanged: (bool value) {
                        print("switched filter");
                        setState(() {
                                  isFilterSwitched = value;
                                  });

                      },

                      height : 55,
                      animationDuration : const Duration(milliseconds: 400),
                      onTap:(){},
                      onDoubleTap:(){},
                      onSwipe:(){},
                      textOff : "Asset Classes",
                      textOn : "Sites",
                      colorOn : Theme.of(context).colorScheme.primary,
                      colorOff : Theme.of(context).colorScheme.secondary,
                      background : const Color(0xffe4e5eb),
                      buttonColor : const Color(0xfff7f5f7),
                    //  inactiveColor : const Color(0xffff8f8),
                    )
                )


        ),
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
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
            height: 100,
            child: DrawerHeader(
              padding: EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CheckboxListTile(
                    value: selectAll,
                    onChanged: (value) {
                      setState(() {
                        selectAll = value!;

                        if (isFilterSwitched) {
                          filteredSites.forEach((element) {
                            element.checked = value;
                          });
                        } else {
                          filteredAssetClasses.forEach((element) {
                            element.checked = value;
                          });
                        }
                      });
                    },
                    title: Text("Select all", style: Theme.of(context).textTheme.bodyMedium)
                  )
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
    child: Icon(
      Icons.holiday_village_outlined,
      color: Colors.grey,
      size: 24.0,
      semanticLabel: 'Text to announce in accessibility modes',
    ),
      //   Image.network(protocol +
//    '://' +
//    serverAddress +
//    port + '/api/static/' +
//    filteredSites
//        .firstWhere((element) =>
//    element.name ==
//    filteredSites[index].name)
//        .imageName)
    ));
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
    print("No filter being used");
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
        //            secondary: Container(
        //            height: 30,
        //            child: Image.network(protocol +
        //            '://' +
        //            serverAddress +
        //            port + '/api/static/' +
        //            filteredAssetClasses
        //                .firstWhere((element) =>
        //            element.assetClass ==
        //            filteredAssetClasses[index]
        //                .assetClass)
        //                .imageName)
        //            )
    );
    }
    });
    }),
    )
    ]
    ])));
    }
}

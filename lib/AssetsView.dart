import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:alerts/BarChart.dart';
import 'package:alerts/Gague.dart';
import 'package:alerts/LineChart.dart';
import 'package:alerts/ScanPage.dart';
import 'package:alerts/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'AddAsset.dart';
import 'AppMessages.dart';
import 'AssetConsumer.dart';
import 'Site.dart';
import 'Ticket.dart';
import 'globals.dart' as globals;

class AssetsView extends StatefulWidget {
  var currentResult;

  void showFindMyDialog(BuildContext context, String code) {
    _showMyDialog(context, null, null, code, code);
  }

  @override
  _AssetsView createState() => _AssetsView();
}

class _AssetsView extends State<AssetsView> {
  var toPrint = [];

  @override
  Widget build(BuildContext context) {
    int count;


    if (MediaQuery.of(context).orientation == Orientation.landscape)
      count = 3;
    else
      count = 1;

    var enabledSites = Provider.of<Sites>(context)
        .sites
        .where((element) => element.checked == true)
        .toList();

    return Consumer<Assets>(builder: (context, data, _) {
      var enabledAssets = data.assets
          .where((element) => enabledSites
              .where((site) => site.name == element.site)
              .isNotEmpty)
          .toList();

      Set<String> sitesSet = Set();
      for (var a in enabledAssets) {
        sitesSet.add(a.site);
      }
      var sitesList = sitesSet.toList();

      return ListView.builder(
          itemCount: sitesList.length,
          itemBuilder: (context, group_index) {
            return StickyHeader(
                header: Container(
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                                color: Colors.black12,
                                height: 30,
                                child: Image.network(protocol +
                                    '://' +
                                    serverAddress +
                                    ':8080/landscaper-service/api/static/' +
                                    sites.sites
                                        .firstWhere((element) =>
                                            element.name ==
                                            sitesList[group_index])
                                        .imageName)),
                            Text(
                              sitesList[group_index],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.normal),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_box),
                              tooltip: 'Create Asset',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) => AddAsset(
                                        site: sitesList[group_index],
                                        stompClient: stompClient),
                                    fullscreenDialog: true,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.print),
                              tooltip: 'Print ',
                              onPressed: () async {
                                final doc = pw.Document();
                                doc.addPage(
                                    pw.Page(build: (pw.Context context) {
                                  List<pw.Widget> barcodes = [];

                                  var start = 0;
                                  var end =
                                      toPrint.length > 3 ? 3 : toPrint.length;

                                  while (toPrint.length != 0 &&
                                      start != toPrint.length) {
                                    var row = toPrint.getRange(start, end);
                                    start = end <= toPrint.length
                                        ? end
                                        : toPrint.length;
                                    end = end + 3 < toPrint.length
                                        ? end + 3
                                        : toPrint.length;

                                    //toPrint.removeRange(0, 3);
                                    List<pw.Widget> cells = [];

                                    row.forEach((element) {
                                      cells.add(pw.SizedBox(
                                        width: 70,
                                        height: 100,
                                        child: pw.Column(children: [
                                          pw.BarcodeWidget(
                                            padding: pw.EdgeInsets.all(1.0),
                                            data: element,
                                            width: 50,
                                            height: 50,
                                            barcode: pw.Barcode.qrCode(),
                                          ),
                                          pw.Text(element)
                                        ]),
                                      ));

                                      cells.add(pw.Padding(
                                          padding: pw.EdgeInsets.only(
                                              right: 140.0, bottom: 110.0)));

                                      //toPrint.remove(element);
                                    });

                                    barcodes.add(pw.Row(children: [...cells]));
                                  }

                                  return pw.Column(children: barcodes);

                                  // Center
                                })); // Page

                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) => Scaffold(
                                        appBar: AppBar(
                                          title: Text("Asset Tag"),
                                        ),
                                        body: PdfPreview(
                                          build: (format) => doc.save(),
                                        )),
                                    fullscreenDialog: true,
                                  ),
                                );
                              },
                            )
                          ],
                        ))),
                content: Container(
                    child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 300,
                                childAspectRatio: 0.6,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5),
                        itemCount: enabledAssets
                            .where((element) =>
                                element.site == sitesList[group_index])
                            .length,
                        itemBuilder: (BuildContext ctx, index) {
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: enabledAssets
                                      .where((element) =>
                                          element.site ==
                                          sitesList[group_index])
                                      .elementAt(index)
                                      .getIcon(30.0),
                                  title: Text(
                                    enabledAssets
                                        .where((element) =>
                                            element.site ==
                                            sitesList[group_index])
                                        .elementAt(index)
                                        .name,
                                  ),
                                  subtitle: Text(
                                    enabledAssets
                                        .where((element) =>
                                            element.site ==
                                            sitesList[group_index])
                                        .elementAt(index)
                                        .type,
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                Container(
                                    alignment: Alignment.centerLeft,
                                    height: 80,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        enabledAssets
                                            .where((element) =>
                                                element.site ==
                                                sitesList[group_index])
                                            .elementAt(index)
                                            .description,
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.6)),
                                      ),
                                    )),
                                Container(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                      Row(children: [
                                        Icon(Icons.warning,
                                            color: Colors.blue, size: 30),
                                        Text(enabledAssets
                                            .where((element) =>
                                                element.site ==
                                                sitesList[group_index])
                                            .elementAt(index)
                                            .activeAlerts)
                                      ]),
                                      Row(children: [
                                        Icon(Icons.traffic,
                                            color: enabledAssets
                                                        .where((element) =>
                                                            element.site ==
                                                            sitesList[
                                                                group_index])
                                                        .elementAt(index)
                                                        .status ==
                                                    "Inactive"
                                                ? Colors.green
                                                : Colors.deepOrange,
                                            size: 30),
                                      ]),
                                      Row(children: [
                                        Icon(Icons.confirmation_number_outlined,
                                            color: Colors.blue, size: 30),
                                        Text(enabledAssets
                                            .where((element) =>
                                                element.site ==
                                                sitesList[group_index])
                                            .elementAt(index)
                                            .tickets)
                                      ])
                                    ])),
                                if (userDetails.featureToggles
                                    .contains("qr")) ...[
                                  Expanded(
                                      child: Column(children: [
                                    QrImage(
                                      data: enabledAssets
                                              .where((element) =>
                                                  element.site ==
                                                  sitesList[group_index])
                                              .elementAt(index)
                                              .site +
                                          "," +
                                          enabledAssets
                                              .where((element) =>
                                                  element.site ==
                                                  sitesList[group_index])
                                              .elementAt(index)
                                              .name
                                              .toString(),
                                      version: QrVersions.auto,
                                      size: 80.0,
                                    ),
                                    Row(children: [
                                      IconButton(
                                          color: toPrint.contains(enabledAssets
                                                  .where((element) =>
                                                      element.site ==
                                                      sitesList[group_index])
                                                  .elementAt(index)
                                                  .name
                                                  .toString())
                                              ? Colors.red
                                              : Colors.blue,
                                          onPressed: () async {
                                            setState(() {

                                            var asset = enabledAssets
                                                  .where((element) =>
                                              element.site ==
                                                  sitesList[group_index])
                                                  .elementAt(index)
                                                  .name
                                                  .toString();

                                            if(toPrint.contains(asset)){
                                              toPrint.remove(asset);
                                            }else{
                                              toPrint.add(asset);
                                            }


                                            });

                                          },
                                          icon: Icon(Icons
                                              .dashboard_customize_outlined)),
                                      IconButton(
                                          icon: Icon(Icons.qr_code_outlined),
                                          color: Colors.blue,
                                          onPressed: () async {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute<void>(
                                                  builder: (BuildContext
                                                          context) =>
                                                      Scaffold(
                                                          appBar: AppBar(
                                                            title: Text(
                                                                "Asset Tag"),
                                                          ),
                                                          body:
                                                              AppBarcodeScannerWidget
                                                                  .defaultStyle(
                                                            resultCallback:
                                                                (String code) {
                                                              Navigator.pop(
                                                                  context);

                                                              var asset = enabledAssets
                                                                  .where((element) =>
                                                                      element
                                                                          .site ==
                                                                      sitesList[
                                                                          group_index])
                                                                  .elementAt(
                                                                      index);

                                                              _showMyDialog(
                                                                  context,
                                                                  asset.site,
                                                                  asset.name,
                                                                  code,
                                                                  null);
                                                            },
                                                          )),
                                                  fullscreenDialog: false,
                                                ));
                                          })
                                    ]),
                                  ]))
                                ]
                              ],
                            ),
                          );
                        })));
          });
    });
  }
}

Future<void> _showMyDialog(context, site, name, result, toFind) async {
  if (toFind == null) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify Asset'),
          content: SizedBox(
              width: double.infinity,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (result == site + "," + name) ...[
                      Icon(Icons.verified,
                          size: 250, color: Colors.greenAccent),
                      Text("Asset Verified")
                    ],
                    if (result != site + "," + name) ...[
                      Icon(Icons.restart_alt,
                          size: 250, color: Colors.greenAccent),
                      Text("Not the asset your looking for")
                    ]
                  ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } else {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify Asset'),
          content: SizedBox(
              width: double.infinity,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restart_alt,
                        size: 250, color: Colors.greenAccent),
                    Text(toFind)
                  ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

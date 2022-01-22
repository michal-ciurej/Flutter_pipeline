
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

import 'AppBarcodeScannerWidget.dart';

class ScanPage extends StatefulWidget {
  var codeToVerify;

  ScanPage( this.codeToVerify);

  @override
  _ScanPageState createState() => _ScanPageState(codeToVerify);
}

class _ScanPageState extends State<ScanPage> {

  var mode = "waiting";
  bool backCamera = true;
  var codeToVerify;

  var currentResult;

  _ScanPageState(this.codeToVerify);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text("Validate Asset"),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          
          if (mode == "waiting") ...[
            Expanded(child:Stack(
              children: [
                QRCodeDartScanView(
                  scanInvertedQRCode: true,
                  onCapture: (Result result) {
                    setState(() {
                      currentResult = result;
                      print(result.text);
                    });
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Text: ?? '),
                        Text(
                            'Format: '),
                      ],
                    ),
                  ),
                ),
              ],
            )),
          ],
          if (mode == "verified")
            SizedBox(
                width: double.infinity,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified,
                          size: 250, color: Colors.greenAccent),
                      Text("Asset Verified")
                    ]))
          else if (mode == "failed")
            SizedBox(
                width: double.infinity,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel, size: 250, color: Colors.deepOrange),
                      Text("Incorrect Asset, rescan"),
                      IconButton(
                        iconSize: 75,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.restart_alt),
                        onPressed: () async {
                          setState(() {
                            mode = "waiting";
                          });
                        },
                      )
                    ]))
        ]));
  }


}


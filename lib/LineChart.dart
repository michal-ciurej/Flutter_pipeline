import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'AppMessages.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'BarChart.dart';
import 'Telemetry.dart';

class LineChart extends StatefulWidget {
  late WebViewController _webViewController;
  StompClient client;



  LineChart({required StompClient this.client});

  @override
  _LineChart createState() => _LineChart(client);





}


class _LineChart extends State<LineChart> {
  StompClient client;
  Timer? timer;
  _LineChart(StompClient this.client);
  var data = [];

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final data = [
      new OrdinalSales('2014', 5),
      new OrdinalSales('2015', 25),
      new OrdinalSales('2016', 100),
      new OrdinalSales('2017', 75),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }

  @override
  void initState() {
    super.initState();
    client.subscribe(
      destination: '/user/topic/telemetry/linechart',
      callback: (frame) {
        Map<String, dynamic> result =
        Map<String, dynamic>.from(json.decode(frame.body!));

        setState(() {

          if(data.length >10){
            timer?.cancel();
            timer = Timer.periodic(Duration(seconds: 2  ), (Timer t) => {client.send(
              destination: '/app/telemetry/linechart',
            )});
          }

          if(data.length > 30) {
            print("Removing start of the data list");
            data.removeAt(0);
          }
          data.add(frame.body);
        });





      },
    );

    timer = Timer.periodic(Duration(seconds: 1  ), (Timer t) => {client.send(
      destination: '/app/telemetry/linechart',
    )});



  }

  @override
  Widget build(BuildContext context)  {


    return Scaffold(
        appBar: AppBar(
        title: const Text("Live Alarm Points"),
    ),
    body: Container(
      alignment: Alignment(0.0, 0.0),
      child:    new charts.BarChart(
        _createSampleData(),
        animate: true,
        vertical: false,
      ),
      width: 500,
      height: 600,
    )
    );

  }

}






import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

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

import 'package:charts_flutter/flutter.dart' as charts;

class Gague extends StatefulWidget {
  late WebViewController _webViewController;
  StompClient client;

  Gague({required StompClient this.client});

  @override
  _Gague createState() => _Gague(client);
}

class _Gague extends State<Gague> {
  StompClient client;
  Timer? timer;
  var createSampleData;

  _Gague(StompClient this.client) {
    Map<String, dynamic> data = {'a': 1, 'b': 2, 'c': 3};
    createSampleData = _createSampleData(data);

    client.subscribe(
      destination: '/user/topic/telemetry/gague',
      callback: (frame) {
        Map<String, dynamic> result =
            Map<String, dynamic>.from(json.decode(frame.body!));

        //setState(() {
        //createSampleData = _createSampleData(result);

        //});
      },
    );

    timer = Timer.periodic(
        Duration(seconds: 1),
        (Timer t) => {
              client.send(
                destination: '/app/telemetry/gague',
              )
            });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<GaugeSegment, String>> _createSampleData(
      Map<String, dynamic> result) {
    final data = [
      new GaugeSegment('Low', 5),
      new GaugeSegment('Acceptable', 12),
      new GaugeSegment('High', 8),
      new GaugeSegment('Highly Unusual', 5),
    ];

    return [
      new charts.Series<GaugeSegment, String>(
        id: 'Segments',
        domainFn: (GaugeSegment segment, _) => segment.segment,
        measureFn: (GaugeSegment segment, _) => segment.size,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Live Alarm Points"),
        ),
        body: Container(
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                    height: 300,
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                          Text(
                            'Ventas en los ultimos 5 años',
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          Flexible(
                            child: charts.PieChart(createSampleData,
                                animate: false,
                                // Configure the width of the pie slices to 30px. The remaining space in
                                // the chart will be left as a hole in the center. Adjust the start
                                // angle and the arc length of the pie so it resembles a gauge.
                                defaultRenderer: new charts.ArcRendererConfig(
                                    arcWidth: 30,
                                    startAngle: 4 / 5 * pi,
                                    arcLength: 7 / 5 * pi)),
                          )
                        ]))))));
  }
}

class GaugeSegment {
  final String segment;
  final int size;

  GaugeSegment(this.segment, this.size);
}

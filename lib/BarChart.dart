import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'AppMessages.dart';
import 'Telemetry.dart';

class BarChart extends StatefulWidget {

  StompClient client;


  BarChart({required StompClient this.client});

  @override
  _BarChart createState() => _BarChart(client);


}



class _BarChart extends State<BarChart> {
  StompClient client;
  Timer? timer;
  List<int> data = [50, 0, 0, 0, 0, 0];
  var option;
  var  chart ;

  /// Create one series with sample hard coded data.
  static List<charts.Series<OrdinalSales, String>> _createSampleData(List<int> dataIn) {
    final data = [
      new OrdinalSales('2014', dataIn[0]),
      new OrdinalSales('2015', dataIn[1]),
      new OrdinalSales('2016', dataIn[2]),
      new OrdinalSales('2017', dataIn[3]),
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


   late List<charts.Series> seriesList;
   var createSampleData;




  _BarChart(StompClient this.client){

    data = [50, 0, 0, 0, 0, 0];
    createSampleData = _createSampleData(data);

    client.subscribe(
      destination: '/user/topic/telemetry/bar',
      callback: (frame) {
        Map<String, dynamic> result =
        Map<String, dynamic>.from(json.decode(frame.body!));

        setState(() {
          if (data.length > 10) {
            timer?.cancel();
            timer = Timer.periodic(Duration(seconds: 2), (Timer t) =>
            {client.send(
              destination: '/app/telemetry/bar',
            )});
          }
          print('telemetry recieved');
          data[0] = result['a'];
          data[1] = result['b'];
          data[2] = result['c'];
          data[4] = result['b'] * 1.5;
          data[5] = result['c'] * 2;

          createSampleData = _createSampleData(data);





        });
      },
    );

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) =>
    {client.send(
      destination: '/app/telemetry/bar',
    )});
  }





  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    print("drawing screen");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Live Alarm Summary"),
        ),
        body: new charts.BarChart(
          createSampleData,
          animate: true,
          vertical: false,
        )
    );

  }

}


class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}



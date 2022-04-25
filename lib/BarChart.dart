import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:alerts/AlarmMessagePayload.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'AppMessages.dart';
import 'Telemetry.dart';
import "package:collection/collection.dart";

class BarChart extends StatefulWidget {
  var data;

  BarChart({required this.data});

  @override
  _BarChart createState() => _BarChart(data);
}

class _BarChart extends State<BarChart> {
  var option;
  var chart;
  var data;

  /// Create one series with sample hard coded data.
  static List<charts.Series<OrdinalSales, String>> _createSampleData(
      List<AlarmMessagePayload> dataIn) {
    List<OrdinalSales> data = [];

    dataIn.forEach((newData) {
      if (data.where((element) => element.year == newData.dateTime.split(' ')[1]).isEmpty ==
          true) {
        print('adding new date' + newData.dateTime.split(' ')[1]);
        data.add(new OrdinalSales(newData.dateTime.split(' ')[1], 1));
      } else {
        data.where((element) => element.year == newData.dateTime.split(' ')[1]).first.sales++;
        print('updating existing date' + newData.dateTime.split(' ')[1]);
      }
    });

    data.sort((a, b) => DateFormat("dd-MMM-yyyy")
        .parse(a.year)
        .compareTo(DateFormat("dd-MMM-yyyy").parse(b.year)));

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

  _BarChart(this.data) {

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    createSampleData = _createSampleData(data);
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      _createSampleData(data),
      animate: true,
      vertical: true,
        domainAxis: charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(labelRotation: 60),
        ),
    );
  }
}

class OrdinalSales {
  String year;
  int sales;

  OrdinalSales(this.year, this.sales);
}

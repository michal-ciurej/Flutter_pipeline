import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:alerts/main.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'AppMessages.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'BarChart.dart';
import 'CasesScreen.dart';
import 'Telemetry.dart';
import 'Ticket.dart';

class NfcManager extends StatefulWidget {
  late WebViewController _webViewController;
  StompClient client;

  NfcManager({required StompClient this.client});

  @override
  _NfcManager createState() => _NfcManager(client);
}

class _NfcManager extends State<NfcManager> {

  var client;

  _NfcManager(this.client);

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [Text("NFC manager")],
      ),
    );
  }
}

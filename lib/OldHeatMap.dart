import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import 'AppMessages.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'main.dart';

class HeatMap extends StatelessWidget {
  //late WebViewController _webViewController;

  var chartView =  "<!DOCTYPE html>\n" +
  "<html>\n" +
  "  <head>\n" +
  "    <meta charset=\"utf-8\" />\n" +
  "    <title>ECharts</title>\n" +
  "    <!-- Include the ECharts file you just downloaded -->\n" +
  "    <script src=\"https://cdnjs.cloudflare.com/ajax/libs/echarts/5.2.2/echarts.min.js\"></script>\n" +
  "  </head>\n" +
  "  <body>\n" +
  "    <!-- Prepare a DOM with a defined width and height for ECharts -->\n" +
  "    <div id=\"main\" style=\"height:@screen@px; width=300px\" ></div>\n" +
  "    <script type=\"text/javascript\">\n" +
  "      // Initialize the echarts instance based on the prepared dom\n" +
  "      var myChart = echarts.init(document.getElementById('main'));\n" +
  "\n" +
  "      // Specify the configuration items and data for the chart\n" +
  "      var option = {\n" +
  "        title: {\n" +
  "          text: 'Alert History'\n" +
  "        },\n" +
  "        tooltip: {},\n" +
  "        legend: {\n" +
  "          data: ['alerts']\n" +
  "        },\n" +
  "        xAxis: {\n" +
  "          type: 'category', "+
  "          data: @xaxis@\n" +
  "        },\n" +
  "        yAxis: {},\n" +
  "        series: [\n" +
  "          {\n" +
  "            name: 'alerts',\n" +
  "            type: 'bar',\n" +
  "            data: @values@ \n" +
  "          }\n" +
  "        ]\n" +
  "      };\n" +
  "      myChart.setOption(option);\n" +
  "    </script>\n" +
  "  </body>\n" +
  "</html>";


  Future<Map> fetchChartData() async {
    final response = await http.get(Uri.parse(protocol+"://localhost:' +  '/api/static/test/logo"));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body) as Map;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context)  {

    return
      SizedBox.expand(

          child:
      Container(
          height:600,
          width:300,
        child: Container(
        margin: const EdgeInsets.all(10.0),
    height:600,
    width:300,
    decoration:
    BoxDecoration(border: Border.all(color: Colors.blueAccent)),
    child:
    WebView(
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {

         _loadHtmlFromAssets(webViewController, context);
      },
    ),
    )
    )
      );

  }
   _loadHtmlFromAssets(WebViewController webViewController, BuildContext context) async {
     fetchChartData().then((value) => {
    //_webViewController.loadHtmlString(chartView.replaceAll(RegExp('@xaxis@'), value.keys.toString()).replaceAll( RegExp('@values@'), value.values.toList().toString()))
       webViewController.loadHtmlString(chartView.replaceAll(RegExp('@screen@'),(MediaQuery.of(context).size.height*2).toString()).replaceAll(RegExp('@xaxis@'), value.keys.toList().toString()).replaceAll( RegExp('@values@'), value.values.toList().toString()))
//print(MediaQuery.of(context).size.height)
    });


  }
}
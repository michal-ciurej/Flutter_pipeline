import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import 'AlarmMessagePayload.dart';
import 'SiteDraw.dart';

class AppMessages extends ChangeNotifier {
  List<AlarmMessagePayload> entries = <AlarmMessagePayload>[];

  void add(List<Map<String, dynamic>> alerts) {
    for (Map<String, dynamic> alert in alerts) {
      print('Adding new alarm ' + alert['site']);
      AlarmMessagePayload alarm = new AlarmMessagePayload();
      alarm.id = alert['id'];
      alarm.name = alert['name'];
      alarm.site = alert['site'];
      alarm.status = alert['status'];
      alarm.ack = alert['ack'];
      alarm.caseNumber = alert['caseNumber'];
      alarm.type = alert['type'];
      alarm.asset = alert['asset'];
      alarm.priority = alert['priority'];
      alarm.assetClass = alert['assetClass'];
      alarm.assetType = alert['assetType'];
      alarm.dateTime = alert['dateTime'];
      alarm.sensorId = alert['sensorId'];
      alarm.messageText = alert['messageText'];

      if (entries.indexWhere((element) =>
              element.id == alarm.id && element.site == alarm.site) ==
          -1) {
        entries.add(alarm);

        entries.sort((a, b) => DateFormat("HH:mm dd-MMM-yyyy")
            .parse(b.dateTime)
            .compareTo(DateFormat("HH:mm dd-MMM-yyyy").parse(a.dateTime)));
      }
    }

    notifyListeners();
  }

  void update(Map<String, dynamic> update) {
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].id == update['id']) {
        entries[i].status = update['status'];
        entries[i].ack = update['ack'];
        entries[i].caseNumber = update['caseNumber'];
        entries[i].messageText = update['messageText'];
        // notifyListeners();
        print('updating alarm' +
            entries[i].id +
            ' with status ' +
            entries[i].status);
        if (entries[i].status == 'closed') {
          print('removing alarm with status ' + entries[i].status);
          entries.removeAt(i);
        }
      }
    }
    //entries.sort((a, b) => a.site.compareTo(b.site));
    notifyListeners();
  }

  void cleanUpMessages() {
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].status == 'Inactive' &&
          entries[i].ack.toString().toUpperCase() == 'TRUE')
        entries.removeAt(i);
    }
  }
}

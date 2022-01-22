import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

      //if(entries.indexWhere((element) => element.id = alarm.id) == -1) {
      entries.add(alarm);

      cleanUpMessages();
      entries.sort((a, b) => a.site.compareTo(b.site));
      notifyListeners();
      //}

    }
  }

  void update(Map<String, dynamic> update) {
    for (AlarmMessagePayload alarm in entries) {
      if (alarm.id == update['id']) {
        alarm.status = update['status'];
        alarm.ack = update['ack'];
        alarm.caseNumber = update['caseNumber'];
        // notifyListeners();
        print('updating alarm' + alarm.id + ' with status ' + alarm.status);
        if (alarm.status == 'closed') {
          print('removing alarm with status ' + alarm.status);
          entries.remove(alarm);
        }
      }
    }
    entries.sort((a, b) => a.site.compareTo(b.site));
    notifyListeners();
  }

  void cleanUpMessages() {
    var timeNow = DateTime.now();

    for (AlarmMessagePayload alarm in entries) {
      if (autoPurge && alarm.status == 'Inactive' &&
          alarm.ack.toString().toUpperCase() == 'TRUE' &&
          DateTime.parse(alarm.dateTime)
              .subtract(new Duration(minutes: int.parse(dotenv.env['PURGE_TIME'].toString())))
              .isBefore(timeNow)) {
        print('aging out alarm ' + alarm.id);
        entries.remove(alarm);

      }
    }
  }
}

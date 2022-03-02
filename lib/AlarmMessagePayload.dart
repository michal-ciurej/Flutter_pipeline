class AlarmMessagePayload {
  var id;

  var type;

  var name;

  var asset;

  var status;

  var site;

  var caseNumber;

  var ack;

  var dateTime;

  var assetId;

  var priority;

  var assetClass;

  var assetType;

  var sensorId;

  List<AlarmMessagePayload> fromJson(List<dynamic> alerts) {
    List<AlarmMessagePayload> results = [];

    for (Map<String, dynamic> alert in alerts) {
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
      results.add(alarm);

    }
    return results;
  }


}

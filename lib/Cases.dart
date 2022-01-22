import 'package:flutter/cupertino.dart';

class Cases extends ChangeNotifier {
  List<Case> cases = <Case>[];
  var workflowSteps=[];
  var filter='none';

  void add(List<Map<String, dynamic>> result) {



    for (Map<String, dynamic> r in result) {
      innerloop:

      for(Case c in  cases){
        if(c.id == r['id'])
          {
            c.status= r['status'];
            c.assignee=r['assignee'];
            notifyListeners();
            return ;
          }
      }


      Case newCase = new Case();
      newCase.status = r['status'];
      newCase.site=r['site'];
      newCase.description=r['description'];
      newCase.id=r['id'];
      newCase.alertId = r['alertId'];
      newCase.date= r['date'];
      newCase.assignee=r['assignee'];
      cases.add(newCase);
    }
    notifyListeners();
  }

  void setFilter(String id) {
    filter = id;
    notifyListeners();
  }

  void setWorkflowSteps(List workflowSteps) {
    this.workflowSteps = workflowSteps;
    notifyListeners();
  }
}

class Case {
  var id;

  var type;

  var name;

  var description;

  var site;

  var priority;

  var category;

  var status;

  var alertId;

  var date;

  var assignee;
}

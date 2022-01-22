import 'dart:async';
import 'dart:convert';

import 'package:alerts/BarChart.dart';
import 'package:alerts/Gague.dart';
import 'package:alerts/LineChart.dart';
import 'package:alerts/WorkflowKanban.dart';
import 'package:alerts/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_handler.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'AppMessages.dart';
import 'Cases.dart';
import 'LoginScreen.dart';
import 'Site.dart';
import 'Ticket.dart';
import 'globals.dart' as globals;
import 'package:step_progress_indicator/step_progress_indicator.dart';

class CasesScreen extends StatefulWidget {
  final ValueChanged<String> update;
  final ValueChanged<int> ticket;
  final StompClient client;

  const CasesScreen(
      {Key? key,
      required this.update,
      required this.ticket,
      required this.client})
      : super(key: key);

  @override
  _CasesScreen createState() => _CasesScreen(client);

// CasesScreen(
//     {required this.update, required this.ticket, required this.client});

}

class _CasesScreen extends State<CasesScreen> {
    var progessSteps = <String>[];
  var assignees = <String>["None"];


  bool _customTileExpanded = false;
  late String dropdownValue;
  var isFilterSwitched = false;
  StompClient client;

  _CasesScreen(StompClient this.client);

  @override
  void initState() {
    super.initState();

   userDetails.users.forEach((element) {assignees.add(element.toString());});

    userDetails.workflowSteps.forEach((element) {progessSteps.add(element.toString());});
    dropdownValue = progessSteps[0];

   //progessSteps.clear();


  }


  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

   return Column(children: [
        Row(children: [
          if (MediaQuery.of(context).size.width > 10000) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Tickets",
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
            )
          ],
          // Here, default theme colors are used for activeBgColor, activeFgColor, inactiveBgColor and inactiveFgColor
          Container(child:Expanded(child:SwitchListTile(
            title: const Text('All / My Tickets'),
            value: isFilterSwitched,
            onChanged: (bool value) {
              setState(() {
                isFilterSwitched = value;
              });
            },
            secondary: const Icon(Icons.business_center),
          ))),
        ]),
        Container(
            child: Expanded(child: Consumer<Cases>(builder: (context, data, _) {
              //var cases = data.cases;

              var enabledSites = Provider.of<Sites>(context)
                  .sites
                  .where((element) => element.checked == true)
                  .toList();
              var cases = data.cases
                  .where((element) => enabledSites
                  .where((site) => (site.name == element.site   &&
                  element.status != progessSteps[progessSteps.length - 1]))
                  .isNotEmpty)
                  .toList();

              if(isFilterSwitched){
                cases = cases.where((element) => element.assignee==userDetails.firstName).toList();
              }

              if (Provider.of<Cases>(context).filter != 'none') {
                cases = cases
                    .where((element) =>
                element.alertId == Provider.of<Cases>(context).filter)
                    .toList();
              }

              return ListView.builder(
                  itemCount: cases.length,
                  itemBuilder: (context, index) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) => CaseDetailView(
                                        id: cases[index].id.toString(),
                                        stompClient: client),
                                    fullscreenDialog: true,
                                  ),
                                );
                              },
                              leading: Icon(Icons.build_circle),
                              title: Text(cases[index].site),
                              subtitle: Text(
                                cases[index].id.toString() +
                                    ' - ' +
                                    cases[index].status,
                                style:
                                TextStyle(color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                cases[index].description,
                                style:
                                TextStyle(color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            StepProgressIndicator(
                              totalSteps: progessSteps.length,
                              currentStep:
                              progessSteps.indexOf(cases[index].status) + 1,
                              size: 25,
                              selectedColor: Colors.greenAccent,
                              unselectedColor: Colors.black12,
                              customStep: (index, color, _) =>
                              color == Colors.greenAccent
                                  ? Container(
                                alignment: Alignment.center,
                                color: color,
                                child: Text(progessSteps[index]),
                              )
                                  : Container(
                                color: color,
                                child: Icon(
                                  Icons.remove,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: DropdownButton<String>(
                                      value: progessSteps[
                                      progessSteps.indexOf(cases[index].status)],
                                      alignment: AlignmentDirectional.centerStart,
                                      icon: const Icon(Icons.expand_more),
                                      elevation: 16,
                                      style:
                                      const TextStyle(color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? newValue) {
                                        var shouldContinue = true;
                                        if (progessSteps.indexOf(newValue!) + 1 ==
                                            progessSteps.length) {
                                          shouldContinue = false;

                                          Timer.run(() {
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text(
                                                    'Confirm Ticket Complete'),
                                                content: const Text(
                                                    'Are you sure you want to close this ticket? It will be removed from your view.'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      shouldContinue = false;
                                                      Navigator.pop(
                                                          context, 'Cancel');
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      shouldContinue = true;
                                                      updateStatus(
                                                          newValue, cases, index);
                                                      Navigator.pop(context, 'OK');
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                        }
                                        if (shouldContinue) {
                                          updateStatus(newValue, cases, index);
                                        }
                                      },
                                      items: progessSteps
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                    )),
                                Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: DropdownButton<String>(
                                      value: assignees[
                                      assignees.indexOf(cases[index].assignee)],
                                      alignment: AlignmentDirectional.centerStart,
                                      icon: const Icon(Icons.expand_more),
                                      elevation: 16,
                                      style:
                                      const TextStyle(color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          print('setting dropdown from ' +
                                              dropdownValue +
                                              ' to ' +
                                              newValue! +
                                              ' for message ' +
                                              cases[index].id.toString());
                                          dropdownValue = newValue!;

                                          TicketModel ticket = new TicketModel();
                                          ticket.id = cases[index].id.toString();
                                          ticket.date = cases[index].date;
                                          ticket.assignee = newValue;
                                          ticket.status = cases[index].status;

                                          client.send(
                                              destination: '/app/updateTicket',
                                              body: jsonEncode(ticket.toJson()));
                                        });
                                      },
                                      items: assignees.map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                    ))
                              ],
                            )
                          ]),
                    );
                  });
            })))
      ]);



  }

  void updateStatus(String newValue, List<Case> cases, int index) {
    setState(() {

      dropdownValue = newValue!;

      TicketModel ticket = new TicketModel();
      ticket.id = cases[index].id.toString();
      ticket.date = cases[index].date;
      ticket.status = newValue;
      ticket.assignee = cases[index].assignee;

      client.send(
          destination: '/app/updateTicket', body: jsonEncode(ticket.toJson()));
    });
  }
}

class CaseDetailView extends StatefulWidget {
  var id;
  StompClient stompClient;

  CaseDetailView({required this.id, required this.stompClient});

  @override
  _CaseDetailView createState() => _CaseDetailView(id: id, client: stompClient);
}

class _CaseDetailView extends State<CaseDetailView> {
  var id;
  late StompUnsubscribe listener;
  TicketCommentModel comment = new TicketCommentModel();

  final _formKey = GlobalKey<FormBuilderState>();
  StompClient client;
  List<TicketCommentModel> comments = <TicketCommentModel>[];

  _CaseDetailView({required this.id, required this.client});

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    listener.call();
  }

  @override
  void initState() {
    super.initState();
    comment.ticketId = id;
    comment.raisedBy = userDetails.firstName + ' ' + userDetails.lastName;

    listener = stompClient.subscribe(
      destination: '/user/topic/ticket/comments',
      callback: (frame) {
        List<Map<String, dynamic>> result =
            List<Map<String, dynamic>>.from(json.decode(frame.body!));

        setState(() {
          for (Map<String, dynamic> c in result) {
            TicketCommentModel comment = new TicketCommentModel();

            comment.raisedBy = c['raisedBy'];
            comment.comment = c['comment'];
            comment.id = c['id'];

            comments.add(comment);
          }

          comments.sort((a, b) => a.id.compareTo(b.id));
        });
      },
    );

    TicketModel ticket = new TicketModel();
    ticket.alertId = id;
    stompClient.send(
        destination: '/app/getTicketComments',
        body: jsonEncode(ticket.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Ticket Details: ' + id),
      ),
      body: Container(
          child: Column(children: [
        Expanded(
            child: ListView.builder(
          // Let the ListView know how many items it needs to build.
          itemCount: comments.length,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (context, index) {
            var item = comments[index];

            return ExpansionTile(
                backgroundColor: Colors.white,
                leading: Icon(
                  Icons.chat,
                  size: 30.0,
                ),
                title: Text(item.id.toString()),
                subtitle: Text(item.comment),
                controlAffinity: ListTileControlAffinity.leading,
                children: <Widget>[
                  ListTile(
                      title: Row(children: [
                    Text("Raised By: " + item.raisedBy),
                  ]))
                ]);
          },
        )),
        Center(
          child: FormBuilder(
              key: _formKey,
              initialValue: {
                'date': DateTime.now(),
                'accept_terms': false,
              },
              autovalidateMode: AutovalidateMode.always,
              child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: Card(
                          color: Colors.white,
                          child: Padding(
                              padding: EdgeInsets.all(25.0),
                              child: Column(children: [
                                FormBuilderTextField(
                                  onChanged: (value) {
                                    comment.comment = value;
                                  },
                                  maxLines: 5,
                                  name: 'description',
                                  style: Theme.of(context).textTheme.bodyText1,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(context)
                                  ]),
                                  decoration:
                                      InputDecoration(labelText: "New Comment"),
                                ),
                                const SizedBox(height: 30),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 20)),
                                  onPressed: () {
                                    stompClient.send(
                                      destination: '/app/addTicketComment',
                                      body: json.encode(comment.toJson()),
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Raise Ticket'),
                                ),
                              ])))))),
        )
      ])),
    );
  }
}

class TicketCommentModel {
  var id;

  var ticketId;

  var comment;

  var raisedBy;

  Map<String, dynamic> toJson() => {
        'id': '0',
        'comment': comment,
        'ticketId': ticketId,
        'raisedBy': raisedBy
      };
}

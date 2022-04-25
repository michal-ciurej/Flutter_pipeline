
import 'dart:convert';

import 'package:alerts/AppMessages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:elegant_notification/elegant_notification.dart';

import 'main.dart';



class FullScreenDialog extends StatelessWidget {
  var id;
  TicketModel newTicket = new TicketModel();
  final _formKey = GlobalKey<FormBuilderState>();
  StompClient stompClient;


  FullScreenDialog({required this.id, required this.stompClient});

  @override
  Widget build(BuildContext context) {

    var alert = Provider.of<AppMessages>(context).entries.firstWhere((element) => element.id ==this.id);
    newTicket.alertId=id;
    newTicket.site = alert.site;
    newTicket.date=DateTime.now().toIso8601String();
    newTicket.asset=alert.asset;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('New Ticket for alert ' + id),
      ),
      body: Center(
        child: FormBuilder(
            key: _formKey,
            initialValue: {
              'date': DateTime.now(),
              'accept_terms': false,
            },
            autovalidateMode: AutovalidateMode.always,
            child: Padding(
                padding: EdgeInsets.all(10.0),child:ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: Card(color: Colors.white,child: Padding(
                    padding: EdgeInsets.all(25.0),child:Column(
                    children: [
                      FormBuilderTextField(
                        onChanged: (value){newTicket.description=value;},
                        maxLines: 5,
                        name: 'description',
                        style: Theme.of(context).textTheme.bodyText1,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        decoration: InputDecoration(labelText: "Description"),
                      ),
                      FormBuilderDateTimePicker(
                          name: "date",
                          style: Theme.of(context).textTheme.bodyText1,
                          inputType: InputType.date,
                          validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                          // format: Dat("dd-MM-yyyy"),
                          decoration: InputDecoration(labelText: "Due By"),
                          onChanged:(value){newTicket.date = value!.toIso8601String();}
                      ),
                      FormBuilderDropdown(
                        onChanged: (value){print(value);newTicket.site = value;},
                        name: "site",
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(labelText: "Site"),
                        initialValue: alert.site,
                        hint: Text('Select Site'),
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        items: sites.sites
                            .map((site) => DropdownMenuItem(
                            value: site.name, child: Text(site.name)))
                            .toList(),
                      ),
                      FormBuilderDropdown(
                        onChanged: (value){newTicket.asset = value;},
                        name: "asset",
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(labelText: "Asset"),
                        initialValue: alert.asset,
                        hint: Text('Select Asset'),
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        items: assets.assets.where((element) => element.site == newTicket.site).toList()
                            .map((asset) => DropdownMenuItem(
                            value: asset.name, child: Text(asset.name)))
                            .toList(),
                      ),
                      FormBuilderDropdown(
                        onChanged: (value){newTicket.type = value;},
                        name: "IssueType",
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(labelText: "Issue Type"),
                        // initialValue: 'Male',
                        hint: Text('Select Issue Type'),
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        items: ['Plant Failure', 'Leak', 'Other']
                            .map((type) => DropdownMenuItem(
                            value: type, child: Text("$type")))
                            .toList(),
                      ),const SizedBox(height: 30),
                      ElevatedButton(

                        style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                        onPressed: (){

                        stompClient.send(
                        destination: '/app/newTicket',
                        body: json.encode(newTicket.toJson()),
                        );



                        Navigator.pop(context);



                        },
                        child: const Text('Raise Ticket'),
                      ),
                    ]))
                )
            ))),
      ),
    );
  }
}

class TicketDetails extends StatelessWidget {
  var id;
  var stompClient;

  TicketDetails({this.id, this.stompClient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Ticket Details: ' + id),
      ),
      body: Container(
          child: Column(children: [Text("asasdsd")])),
    );
  }
}
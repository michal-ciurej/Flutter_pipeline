
import 'dart:convert';

import 'package:alerts/AlarmMessagePayload.dart';
import 'package:alerts/AppMessages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:elegant_notification/elegant_notification.dart';

import 'AssetConsumer.dart';
import 'Site.dart';
import 'main.dart';



class RaiseAlert extends StatefulWidget {
  StompClient stompClient;


  RaiseAlert({required this.stompClient});

  @override
  _RaiseAlert createState() =>
      _RaiseAlert();

}

class _RaiseAlert extends State<RaiseAlert> {

  final _formKey = GlobalKey<FormBuilderState>();
  AlarmMessagePayload alert = new AlarmMessagePayload();


  @override
  Widget build(BuildContext context) {


    ValueNotifier notifier;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF25b432),
        title: Text('Raise an Alert'),
      ),
      body: SingleChildScrollView(child:Center(
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
                        onChanged: (value){alert.messageText=value;},
                        maxLines: 2,
                        name: 'description',
                        style: Theme.of(context).textTheme.bodyText1,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        decoration: InputDecoration(labelText: "Alert Description"),
                      ),
                      FormBuilderDropdown(
                        onChanged: (value){
                          setState(() {
                            alert.site = value;
                          });

                          },
                        name: "site",
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(labelText: "Site"),
                        initialValue: sites.sites[0].name,
                        hint: Text('Select Site'),
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        items: sites.sites
                            .map((site) => DropdownMenuItem(
                            value: site.name, child: Text(site.name)))
                            .toList(),
                      ),

                    FormBuilderDropdown(
                        onChanged: (value){alert.assetClass= value;},
                        name: "Asset",
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(labelText: "Asset"),
                        // initialValue: 'Male',
                        hint: Text('Select Asset '),
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        items: assets.assets.where((element) => element.site ==alert.site)
                            .map((asset) => DropdownMenuItem(
                            value: asset.name, child: Text(asset.name)))
                            .toList(),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(

                        style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                        onPressed: (){



                          if (_formKey.currentState!.validate()) {

                            stompClient.send(
                              destination: '/app/alert/new',
                              body: json.encode(alert.toJson()),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Alert Sent'))
                            );
                            Navigator.pop(context);

                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Alert details not complete'))
                            );
                          }






                        },
                        child: const Text('Raise Alert'),
                      ),
                    ]))
                )
            ))),
      ),
      ));
  }
}


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

import 'AssetConsumer.dart';
import 'main.dart';



class ReplaceAsset extends StatelessWidget {
  var site;
  final _formKey = GlobalKey<FormBuilderState>();
  StompClient stompClient;
  Asset originalAsset;



  ReplaceAsset({required this.site, required this.stompClient, required this.originalAsset});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF25b432),
        title: Text('Replace Asset'),
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
                        onChanged: (value){originalAsset.description=value;},
                        maxLines: 2,
                        initialValue: originalAsset.description,
                        name: 'description',
                        style: Theme.of(context).textTheme.bodyText1,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        decoration: InputDecoration(labelText: "Asset Description"),
                      ),
                      FormBuilderTextField(
                        onChanged: (value){originalAsset.name=value;},
                        maxLines: 1,
                        name: 'name',
                        initialValue: originalAsset.name,
                        style: Theme.of(context).textTheme.bodyText1,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        decoration: InputDecoration(labelText: "Asset Short Name"),
                      ),
                      FormBuilderDropdown(
                        onChanged: (value){print(value);originalAsset.site = value;},
                        name: "site",
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(labelText: "Site"),
                        initialValue: originalAsset.site,
                        hint: Text('Select Site'),
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        items: sites.sites
                            .map((site) => DropdownMenuItem(
                            value: site.name, child: Text(site.name)))
                            .toList(),
                      ),
                      FormBuilderDropdown(
                        onChanged: (value){originalAsset.assetClass = value;},
                        name: "Asset Class",
                        initialValue: originalAsset.assetClass,
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(labelText: "Asset Class"),
                        // initialValue: 'Male',
                        hint: Text('Select Asset Class'),
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        items: userDetails.assetClasses
                            .map((type) => DropdownMenuItem(
                            value: type, child: Text("$type")))
                            .toList(),
                      ),
                      FormBuilderDropdown(
                        onChanged: (value){originalAsset.type = value;},
                        name: "Asset Type",
                        initialValue: originalAsset.type,
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(labelText: "Asset Type"),
                        // initialValue: 'Male',
                        hint: Text('Select Asset Type'),
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        items: userDetails.assetTypes
                            .map((type) => DropdownMenuItem(
                            value: type, child: Text("$type")))
                            .toList(),
                      ),
                      FormBuilderTextField(
                        onChanged: (value){originalAsset.manufacturer=value;},
                        maxLines: 1,
                        name: 'manufacturer',
                        initialValue: originalAsset.manufacturer,
                        style: Theme.of(context).textTheme.bodyText1,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        decoration: InputDecoration(labelText: "Manufacturer"),
                      ),
                      FormBuilderTextField(
                        onChanged: (value){originalAsset.model=value;},
                        maxLines: 1,
                        name: 'model',
                        initialValue: originalAsset.model,
                        style: Theme.of(context).textTheme.bodyText1,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        decoration: InputDecoration(labelText: "Model"),
                      ),
                      FormBuilderTextField(
                        onChanged: (value){originalAsset.location=value;},
                        maxLines: 1,
                        name: 'location',
                        initialValue: originalAsset.location,
                        style: Theme.of(context).textTheme.bodyText1,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        decoration: InputDecoration(labelText: "Location"),
                      )
                      ,const SizedBox(height: 30),
                      ElevatedButton(

                        style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                        onPressed: (){



                          if (_formKey.currentState!.validate()) {

                            stompClient.send(
                              destination: '/app/assets/update',
                              body: json.encode(originalAsset.toJson()),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Asset Created'))
                            );
                            Navigator.pop(context);

                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Asset details not complete'))
                            );
                          }






                        },
                        child: const Text('Replace Asset'),
                      ),
                    ]))
                )
            ))),
      ),
      ));
  }
}

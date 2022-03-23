
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



class AddAsset extends StatelessWidget {
  var site;
  var asset = new Asset();
  final _formKey = GlobalKey<FormBuilderState>();
  StompClient stompClient;



  AddAsset({required this.site, required this.stompClient});

  @override
  Widget build(BuildContext context) {
    asset.site=site;


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF25b432),
        title: Text('Add an Asset'),
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
                        onChanged: (value){asset.description=value;},
                        maxLines: 2,
                        name: 'description',
                        style: Theme.of(context).textTheme.bodyText1,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        decoration: InputDecoration(labelText: "Asset Description"),
                      ),
                      FormBuilderTextField(
                        onChanged: (value){asset.name=value;},
                        maxLines: 1,
                        name: 'name',
                        style: Theme.of(context).textTheme.bodyText1,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        decoration: InputDecoration(labelText: "Asset Short Name"),
                      ),
                      FormBuilderDropdown(
                        onChanged: (value){print(value);asset.site = value;},
                        name: "site",
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(labelText: "Site"),
                        initialValue: site,
                        hint: Text('Select Site'),
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        items: sites.sites
                            .map((site) => DropdownMenuItem(
                            value: site.name, child: Text(site.name)))
                            .toList(),
                      ),
                      FormBuilderDropdown(
                        onChanged: (value){asset.assetClass = value;},
                        name: "Asset Class",
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
                        onChanged: (value){asset.type = value;},
                        name: "Asset Type",
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
                        onChanged: (value){asset.manufacturer=value;},
                        maxLines: 1,
                        name: 'manufacturer',
                        style: Theme.of(context).textTheme.bodyText1,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        decoration: InputDecoration(labelText: "Manufacturer"),
                      ),
                      FormBuilderTextField(
                        onChanged: (value){asset.model=value;},
                        maxLines: 1,
                        name: 'model',
                        style: Theme.of(context).textTheme.bodyText1,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                        decoration: InputDecoration(labelText: "Model"),
                      ),
                      FormBuilderTextField(
                        onChanged: (value){asset.location=value;},
                        maxLines: 1,
                        name: 'location',
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
                              destination: '/app/assets/new',
                              body: json.encode(asset.toJson()),
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
                        child: const Text('Add Asset'),
                      ),
                    ]))
                )
            ))),
      ),
      ));
  }
}

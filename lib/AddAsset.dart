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

class AddAsset extends StatefulWidget {
  var site;
  var asset = new Asset();
  final _formKey = GlobalKey<FormBuilderState>();
  StompClient stompClient;

  AddAsset({required this.site, required this.stompClient});

  @override
  _AddAsset createState() => _AddAsset(site, stompClient);
}

class _AddAsset extends State<AddAsset> {

  var site;
  var asset = new Asset();
  final _formKey = GlobalKey<FormBuilderState>();
  StompClient stompClient;
  bool _showManufacturerTextField = false;
  bool _showModelTextField = false;
  bool _showLocationTextField = false;

  _AddAsset(
      String this.site,
      StompClient this.stompClient,

  ){
    asset.site = site;
    asset.manufacturer='New';
    asset.location='New';

  }

  @override
  Widget build(BuildContext context) {

    stompClient.subscribe(
      destination: '/user/topic/eventmessages',
      callback: (frame) {
        String result = frame.body!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
                label: 'Ok',
                onPressed: () {
                  Navigator.pop(context);
                })));
        //Navigator.pop(context);
      },
    );



    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF25b432),
          title: Text('Add an Asset'),
        ),
        body: SingleChildScrollView(
          child: Center(
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
                                      asset.description = value;
                                    },
                                    maxLines: 2,
                                    name: 'description',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(context)
                                    ]),
                                    decoration: InputDecoration(
                                        labelText: "Asset Description"),
                                  ),
                                  FormBuilderTextField(
                                    onChanged: (value) {
                                      asset.name = value;
                                    },
                                    maxLines: 1,
                                    name: 'name',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(context)
                                    ]),
                                    decoration: InputDecoration(
                                        labelText: "Asset Serial Number"),
                                  ),
                                  FormBuilderDropdown(
                                    onChanged: (value) {

                                      asset.site = value;
                                    },
                                    name: "site",
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    decoration:
                                        InputDecoration(labelText: "Site"),
                                    initialValue: site,
                                    hint: Text('Select Site'),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(context)
                                    ]),
                                    items: sites.sites
                                        .map((site) => DropdownMenuItem(
                                            value: site.name,
                                            child: Text(site.name)))
                                        .toList(),
                                  ),
                                  FormBuilderDropdown(
                                    onChanged: (value) {
                                      asset.assetClass = value;
                                    },
                                    name: "Asset Class",
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    decoration: InputDecoration(
                                        labelText: "Asset Class"),
                                    // initialValue: 'Male',
                                    hint: Text('Select Asset Class'),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(context)
                                    ]),
                                    items: userDetails.assetClasses
                                        .map((type) => DropdownMenuItem(
                                            value: type, child: Text("$type")))
                                        .toList(),
                                  ),
                                  FormBuilderDropdown(
                                    onChanged: (value) {
                                      asset.type = value;
                                    },
                                    name: "Asset Type",
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    decoration: InputDecoration(
                                        labelText: "Asset Type"),
                                    // initialValue: 'Male',
                                    hint: Text('Select Asset Type'),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(context)
                                    ]),
                                    items: userDetails.assetTypes
                                        .map((type) => DropdownMenuItem(
                                            value: type, child: Text("$type")))
                                        .toList(),
                                  ),
                                  Column(children: [
                                    Visibility(
                                        visible: !_showManufacturerTextField,
                                        child:
                                    FormBuilderDropdown(
                                      onChanged: (value) {

                                        setState(() {
                                          if(value == 'New') {
                                            _showManufacturerTextField = true;
                                            _showModelTextField=true;
                                          }

                                          asset.manufacturer = value;

                                        });


                                      },
                                      name: "ManufacturerDD",
                                      style:
                                      Theme.of(context).textTheme.bodyText1,
                                      decoration: InputDecoration(
                                          labelText: "Manufacturer"),
                                      // initialValue: 'Male',
                                      hint: Text('Select Manufacturer'),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(context)
                                      ]),
                                      items: assets.manufacturers.keys
                                          .map((type) => DropdownMenuItem(
                                          value: type, child: Text("$type")))
                                          .toList(),
                                    )),
                                    Visibility(
                                        visible: _showManufacturerTextField,
                                        child: FormBuilderTextField(
                                          onChanged: (value) {
                                            asset.manufacturer = value;

                                          },
                                          maxLines: 1,
                                          name: 'ManufacturerTXT',
                                          style:
                                          Theme.of(context).textTheme.bodyText1,
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(context)
                                          ]),
                                          decoration: InputDecoration(
                                              labelText: "Manufacturer"),
                                        ) //Your textfield here,
                                        )
                                  ]),

                                  Column(children: [
                                    Visibility(
                                        visible: !_showModelTextField,
                                        child:
                                        FormBuilderDropdown(
                                          onChanged: (value) {


                                              setState(() {
                                                if(value == 'New') {
                                                  _showModelTextField=true;
                                                }

                                                asset.model = value;

                                              });


                                          },
                                          name: "ModelDD",
                                          style:
                                          Theme.of(context).textTheme.bodyText1,
                                          decoration: InputDecoration(
                                              labelText: "Model"),
                                          // initialValue: 'Male',
                                          hint: Text('Select Model'),
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(context)
                                          ]),
                                          items: assets.manufacturers[asset.manufacturer]!
                                              .map((type) => DropdownMenuItem(
                                              value: type, child: Text("$type")))
                                              .toList(),
                                        )),
                                    Visibility(
                                        visible: _showModelTextField,
                                        child: FormBuilderTextField(
                                          onChanged: (value) {
                                            asset.model = value;
                                          },
                                          maxLines: 1,
                                          name: 'ModelTXT',
                                          style:
                                          Theme.of(context).textTheme.bodyText1,
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(context)
                                          ]),
                                          decoration: InputDecoration(
                                              labelText: "Model"),
                                        ) //Your textfield here,
                                    )
                                  ]),

                                  Column(children: [
                                    Visibility(
                                        visible: !_showLocationTextField,
                                        child:
                                        FormBuilderDropdown(
                                          onChanged: (value) {
                                            if(value == 'New')
                                              setState(() {
                                                _showLocationTextField = true;
                                              });

                                            asset.location = value;
                                          },
                                          name: "LocationDD",
                                          style:
                                          Theme.of(context).textTheme.bodyText1,
                                          decoration: InputDecoration(
                                              labelText: "Location"),
                                          // initialValue: 'Male',
                                          hint: Text('Select Location'),
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(context)
                                          ]),
                                          items: assets.location
                                              .map((type) => DropdownMenuItem(
                                              value: type, child: Text("$type")))
                                              .toList(),
                                        )),
                                    Visibility(
                                        visible: _showLocationTextField,
                                        child: FormBuilderTextField(
                                          onChanged: (value) {
                                            asset.location = value;
                                          },
                                          maxLines: 1,
                                          name: 'LocationTXT',
                                          style:
                                          Theme.of(context).textTheme.bodyText1,
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(context)
                                          ]),
                                          decoration: InputDecoration(
                                              labelText: "Location"),
                                        ) //Your textfield here,
                                    )
                                  ]),
                                  FormBuilderTextField(
                                    onChanged: (value) {
                                      asset.sensorId = value;
                                    },
                                    maxLines: 1,
                                    name: 'sensorId',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    //validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                                    decoration:
                                        InputDecoration(labelText: "Sensor ID"),
                                  ),
                                  const SizedBox(height: 30),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        textStyle:
                                            const TextStyle(fontSize: 20)),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        stompClient.send(
                                          destination: '/app/assets/new',
                                          body: json.encode(asset.toJson()),
                                        );

                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Asset details not complete')));
                                      }
                                    },
                                    child: const Text('Add Asset'),
                                  ),
                                ])))))),
          ),
        ));
  }
}

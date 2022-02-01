import 'dart:convert';
import 'dart:io';

import 'package:alerts/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'Utils.dart';

class LoginScreen extends StatefulWidget {
  late StompClient client;

  LoginScreen({required this.client});

  @override
  _LoginScreen createState() => _LoginScreen(client);
}

class _LoginScreen extends State<LoginScreen> {
  var client;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String company = 'bob';

  Future<void> _getPreferences() async {
    final SharedPreferences prefs = await _prefs;
    final String storedcompany =
        (prefs.getString('company') ?? "192.168.1.142");

    setState(() {
      print('Setting up with server ' + serverAddress);
      company = storedcompany;
    });



  }

  Future<void> _savePreferences(String companyCode) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('company', companyCode);
  }

  @override
  void initState() {
    super.initState();
    _getPreferences();


  }

  _LoginScreen(this.client);

  Duration get loginTime => Duration(milliseconds: 200);

  Future<String?> _authUser(LoginData data) async {




    await validateDetails(data).then((value) {
      userDetails = UserDetails(jsonDecode(value.body));

      print(userDetails.loginMessage);
      if (userDetails.loggedIn == true) {
        return "";
      }

      /*if (value=="password") {
            return 'Password does not match';
          }
          if (value=="user") {
            return 'User not found';
          }*/
      return "errir";
    });
  }

  Future<String?> _signupUser(SignupData data) async {
    print("signing up user");

    data.additionalSignupData!.forEach((key, value) {
      _savePreferences(value);
      print(key + ' ' + value);
    });




    await validateSignupDetails(data).then((value) {
      userDetails = UserDetails(jsonDecode(value.body));

      print(userDetails.loginMessage);
      if (userDetails.loggedIn == true) {
        return "";
      }

      /*if (value=="password") {
            return 'Password does not match';
          }
          if (value=="user") {
            return 'User not found';
          }*/
      return "errir";
    });
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      //if (!users.containsKey(name)) {
      // return 'User not exists';
      // }
      return "null";
    });
  }

//https://pub.dev/packages/flutter_login
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 0.0),
        child: FlutterLogin(
          messages: LoginMessages(
            flushbarTitleSuccess: 'You are now setup for your company portal',
          ),
          savedEmail: "bob@test.com",
          savedPassword: "asdasd",
          title: dotenv.env['CUSTOMER'].toString(),
          logo: new NetworkImage(
              protocol + '://' + serverAddress + port + '/api/static/pub3.jpeg'),
          onLogin: _authUser,
          //onSignup: _signupUser,
          /*additionalSignupFields: [
            UserFormField(
                defaultValue: serverAddress,
                keyName: 'Company Code',
                icon: Icon(FontAwesomeIcons.chrome))
          ],*/
          onSubmitAnimationCompleted: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const MyHomePage(),
            ));
          },
          onRecoverPassword: _recoverPassword,
        ));
  }

  Future<http.Response> validateDetails(LoginData data) async {
    final response = http.post(
      Uri.parse(protocol + '://' + serverAddress +  port + '/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'name': data.name, 'password': data.password}),
    );
    return response;
  }

  Future<http.Response> validateSignupDetails(SignupData data) async {
    final response = http.post(
      Uri.parse(protocol + '://' + serverAddress +  port + '/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'name': data.name!, 'password': data.password!}),
    );
    return response;
  }
}

class UserDetails {
  var loginMessage;
  var loggedIn;
  var email;
  var firstName;
  var lastName;
  var featureToggles = [];
  var users = [];
  var workflowSteps = [];

  UserDetails(json) {
    this.loggedIn = json['loggedIn'];
    this.loginMessage = json['loginMessage'];
    this.email = json['email'];
    this.firstName = json['firstName'];
    this.lastName = json['lastName'];
    this.featureToggles = json['featureToggles'];
    this.users = json['users'];
    this.workflowSteps = json['workflowSteps'];
    cases.setWorkflowSteps(workflowSteps);
  }
}

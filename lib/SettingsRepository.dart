import 'dart:convert';

import 'package:alerts/AssetConsumer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';

import 'Site.dart';


class SettingsRepository {



  static String encodeSites(List<Site> sites) => json.encode(
    sites
        .map<Map<String, dynamic>>((site) => Site.toMap(site))
        .toList(),
  );

  static List<Site> decodeSites(String sites) =>
      (json.decode(sites) as List<dynamic>)
          .map<Site>((item) => Site.fromJson(item))
          .toList();



  static Future<Null> saveSites(List<Site> sites) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sites', encodeSites(sites));

  }

  static Future<List<Site>> loadSites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? sites = await prefs.getString('sites') ?? "_";

    if(sites == "_"){
      return  <Site>[];

    }else {
      return decodeSites(sites!);
    }
  }

  static Future<Null> saveAssets(List<AssetClass> assets) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('assets', encodeAssets(assets));

  }

  static String encodeAssets(List<AssetClass> assets) => json.encode(
    assets
        .map<Map<String, dynamic>>((asset) => AssetClass.toMap(asset))
        .toList(),
  );

  static List<AssetClass> decodeAssets(String assets) =>
      (json.decode(assets) as List<dynamic>)
          .map<AssetClass>((item) => AssetClass.fromJson(item))
          .toList();

  static Future<List<AssetClass>> loadAssets() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? assets = await prefs.getString('assets') ?? "_";

    if(assets == "_"){
      return  <AssetClass>[];

    }else {
      return decodeAssets(assets!);
    }
  }

}
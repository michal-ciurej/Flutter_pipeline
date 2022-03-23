import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'SettingsRepository.dart';
import 'main.dart';

class Sites extends ChangeNotifier {
  List<Site> sites = <Site>[];

  void add(List<Map<String, dynamic>> _site) {
    SettingsRepository.loadSites().then((value) {
      sites.clear();
      for (Map<String, dynamic> s in _site) {
        Site site = new Site();
        site.name = s['name'];

        if(value.where((element) => element.name==site.name).isNotEmpty){
          site.checked = value.where((element) => element.name==site.name).first.checked;
        }else {
          site.checked = s['selected'];
        }
        //site.image=s['image'];
        site.imageName = s['imageName'];
        sites.add(site);
      }
      notifyListeners();
    });
  }

  void update(index, value) {
    sites[index].checked = value;
    notifyListeners();
  }
}

class Site {
  var name;
  var checked;
  var image;
  var imageName;
  var expanded = false;

  Site({this.name, this.checked});

  static Map<String, dynamic> toMap(Site site) => {
        'name': site.name,
        'checked': site.checked,
      };

  factory Site.fromJson(Map<String, dynamic> jsonData) {
    return Site(name: jsonData['name'], checked: jsonData['checked']);
  }
}

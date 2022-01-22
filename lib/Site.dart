
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class Sites extends ChangeNotifier{

  List<Site> sites = <Site>[];

  void add(List<Map<String, dynamic>> _site) {

    sites.clear();
    for(Map<String, dynamic> s in _site) {
      Site site = new Site();
       site.name = s['name'];
       site.checked = s['selected'];
       //site.image=s['image'];
       site.imageName=s['imageName'];
       sites.add(site);


    }
    notifyListeners();

  }

  void update(index, value) {
    sites[index].checked=value;
    notifyListeners();

  }
}

class Site {
  var name;
  var checked;
  var image;
  var imageName;




}



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SettingsRepository.dart';

class Assets extends ChangeNotifier {
  List<Asset> assets = [];
  List<AssetClass> assetClasses = [];

  void add(List<Map<String, dynamic>> results) {
    SettingsRepository.loadAssets().then((value) {
      for (Map<String, dynamic> a in results) {
        Asset asset = new Asset();
        asset.name = a['name'];
        asset.model = a['model'];
        asset.location = a['location'];
        asset.id = a['id'];
        asset.type = a['type'];
        asset.status = a['status'];
        asset.description = a['description'];
        asset.site = a['site'];
        asset.activeAlerts = a['activeAlerts'];
        asset.tickets = a['tickets'];
        asset.assetClass = a['assetClass'];
        if (value
            .where((element) => element.assetClass == asset.assetClass)
            .isNotEmpty) {
          asset.checked = value
              .where((element) => element.assetClass == asset.assetClass)
              .first
              .checked;
        } else {
          asset.checked = true;
        }
        asset.imageName = 'pub.png';

        asset.manufacturer = a['manufacturer'];

        asset.sensorId = a['sensorId'];

        var index = assets.indexWhere((element) => element.id == asset.id);

        if (index == -1) {
          assets.add(asset);
        } else {
          assets.removeAt(index);
          assets.add(asset);
        }

        if (assetClasses.indexWhere(
                (element) => element.assetClass == asset.assetClass) ==
            -1) {
          assetClasses.add(AssetClass(asset.assetClass, asset.checked));
        }
      }

      for(int i = 0; i< assets.length; i++) {
        if(assets[i].status=='replaced'){
          assets.removeAt(i);
        }
      }


      notifyListeners();
    });
  }

  void update(index, value) {
    assets[index].checked = value;
    notifyListeners();
  }

  void updateAssetClass(int index, bool? value) {
    assetClasses[index].checked = value;
    notifyListeners();
  }
}

class AssetClass {
  var assetClass;
  var checked;

  AssetClass(this.assetClass, this.checked);

  static Map<String, dynamic> toMap(AssetClass assetClass) => {
        'assetClass': assetClass.assetClass,
        'checked': assetClass.checked,
      };

  factory AssetClass.fromJson(Map<String, dynamic> jsonData) {
    return AssetClass(jsonData['assetClass'], jsonData['checked']);
  }
}

class Asset {
  var id;
  var name;
  var type;
  var status;
  var description;
  var site;
  var activeAlerts;
  var tickets;
  var checked;
  var imageName;
  var assetClass;
  var manufacturer;
  var model;
  var location;
  var sensorId;


  Icon getIcon(var size) {
    switch (type) {
      case 'hvac':
        return Icon(
          Icons.hvac,
          color: Colors.amberAccent,
          size: size,
        );
        break;
      case 'fridge':
        return Icon(Icons.kitchen, color: Colors.blue, size: size);
        break;
      case 'lights':
        return Icon(Icons.emoji_objects, color: Colors.orange, size: size);
        break;
      default:
        return Icon(Icons.hvac, color: Colors.amberAccent, size: size);
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'site': site,
        'type': type,
        'assetClass': assetClass,
        'status': status,
        'manufacturer': manufacturer,
        'model': model,
        'location': location,
        'id':id,
        'sensorId': sensorId
      };
}

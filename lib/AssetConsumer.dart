
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Assets extends ChangeNotifier {
  List<Asset> assets = [];
  List<AssetClass> assetClasses= [];

  void add(List<Map<String, dynamic>> results) {

    for (Map<String, dynamic> a in results) {
      Asset asset = new Asset();
      asset.name = a['name'];
      asset.id = a['id'];
      asset.type = a['type'];
      asset.status = a['status'];
      asset.description = a['description'];
      asset.site = a['site'];
      asset.activeAlerts = a['activeAlerts'];
      asset.tickets=a['tickets'];
      asset.checked=true;
      asset.imageName='pub.png';
      asset.assetClass = a['assetClass'];
      asset.manufacturer=a['manufacturer'];




      var index = assets.indexWhere((element) => element.id == asset.id);

      if(index == -1){
        assets.add(asset);
      }else{
        assets.removeAt(index);
        assets.add(asset);
      }

      if(assetClasses.indexWhere((element) => element.assetClass==asset.assetClass) ==-1){
        assetClasses.add(AssetClass(asset.assetClass, asset.checked, 'pub.png'));
      }


    }

    notifyListeners();

  }


  void update(index, value) {
    assets[index].checked=value;
    notifyListeners();

  }

  void updateAssetClass(int index, bool? value) {
    assetClasses[index].checked=value;
    notifyListeners();
  }


}

class AssetClass {
  var assetClass;
  var checked;
  var imageName;

  AssetClass(this.assetClass, this.checked, this.imageName);
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


  Icon getIcon(var size){

      switch(type){
        case 'hvac':
          return Icon(Icons.hvac,color: Colors.amberAccent, size: size,);
        break;
        case 'fridge':
          return Icon(Icons.kitchen, color:Colors.blue, size: size);
          break;
        case 'lights':
          return Icon(Icons.emoji_objects, color:Colors.orange, size: size);
          break;
        default:
          return Icon(Icons.hvac,color: Colors.amberAccent, size: size);
      }


  }
}
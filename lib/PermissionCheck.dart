

import 'package:alerts/main.dart';
import 'package:flutter/material.dart';

class PermissionCheck{

   static String ACK_ALARM = "ack_alarm";
   static String CLOSE_ALARM = "close_alarm";

  static bool check(String permission, BuildContext context) {

    if(userDetails.permissionToggles.contains(permission)){
      return true;
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No permission to take this action')));
      return false;
    }

  }

}
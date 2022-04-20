import 'package:alerts/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PermissionCheck {
  static String ACK_ALARM = "ack_alarm";
  static String CLOSE_ALARM = "close_alarm";
  static String RAISE_ALERT = "raise_alert";
  static String ADD_ASSET = "add_asset";
  static String SWAP_ASSET = "swap_asset";
  static String PRINT_ASSET = "print_asset";
  static String SEND_MESSAGE = "send_message";
  static String EDIT_ASSET="edit_asset";

  static bool check(String permission, BuildContext context) {
    if (dotenv.env['PERMISSION_CHECK'].toString() == "false" ||
        userDetails.permissionToggles.contains(permission)) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          content: Text('No permission to take this action')));
      return false;
    }
  }
}

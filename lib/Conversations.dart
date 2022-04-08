import 'dart:convert';

import 'package:alerts/Messages.dart';
import 'package:alerts/main.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class Conversations extends ChangeNotifier {
  List<Conversation> conversations = [];

  void add(List<Map<String, dynamic>> results) {
    for (Map<String, dynamic> a in results) {

      Conversation conversation = Conversation(null, []);
      conversation.id = a['id'];
      conversation.source = a['author'];



      for (Map<String, dynamic> message in a['messages']) {

        if(message['type'] == "text") {
          conversation.messages.add(types.TextMessage(
            author: types.User.fromJson(
                message['author'] as Map<String, dynamic>),
            createdAt: int.parse(message['createdAt']),
            id: message['id'],
            //metadata: message['metadata'] as Map<String, dynamic>?,
            roomId: message['roomId'],
            text: message['text'],
            // repliedMessage: message['repliedMessage'],
            type: types.MessageType.text,
          ));
        }
        if(message['type'] == "image") {
          conversation.messages.add(types.ImageMessage(
              author: types.User.fromJson(
                  message['author'] as Map<String, dynamic>),
              createdAt: int.parse(message['createdAt']),
              height: double.parse(message['height']),
              id: message['id'],
              name: message['name'],
              size: num.parse(message['size']),
              uri: message['uri'],
              width: double.parse(message['width']),
              roomId: conversation.id,
              status: types.Status.delivered
          ));
        }

      }

      conversation.messages.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

      conversation.targets=a['participants'];


      if(conversation.targets.contains(userDetails.firstName) || conversation.source==userDetails.firstName) {
        for(int i=0; i< conversations.length;i++){
          if(conversations[i].id == conversation.id)
            conversations.removeAt(i);
        }
        this.conversations.add(conversation);

      }
    }
    notifyListeners();


  }
}



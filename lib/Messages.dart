import 'dart:convert';

import 'package:alerts/Conversations.dart';
import 'package:alerts/LoginScreen.dart';
import 'package:alerts/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';



class ChatMessages extends StatefulWidget {
  Conversation conversation;

  ChatMessages(this.conversation);

  @override
  _ChatMessages createState() => _ChatMessages(conversation);
}

class _ChatMessages extends State<ChatMessages> {
  Conversation conversation;

  _ChatMessages(this.conversation);

  void _loadMessages() async {
    final response = await rootBundle.loadString('/messages.json');
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = [for(var e in conversation.messages) e as types.Message];
    });
  }

  List<types.Message> _messages = [];
  final _user =  types.User(id: userDetails.firstName!);

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
      roomId: conversation.id
    );
//send this to the server.
    _addMessage(textMessage);
  }

  void _addMessage(types.Message message) {

    conversation.messages.add(message);

    stompClient.send(
      destination: '/app/conversation/new',
      body: json.encode(conversation.toJson()),
    );


    setState(() {
      _messages.insert(0, message);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 80,
        title: Container(
          child: Container(
            // DefaultTextStyle: TextStyle(color: Colors.red),
            padding: EdgeInsets.only(top: 20),
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(0.3),
                1: FlexColumnWidth(0.7),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.top,
                      child: Container(
                        height: 25,
                        //width: 32,
                        color: Colors.transparent,
                        child: Text("Message:",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                ?.copyWith(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary)
                            //GoogleFonts.roboto(
                            //    fontSize: 14,
                            //    fontWeight:
                            //    FontWeight.w200)
                            ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
      ),
      body: SafeArea(
        bottom: false,
        child: Chat(
          messages: _messages,
          //onAttachmentPressed: _handleAtachmentPressed,
          //onMessageTap: _handleMessageTap,
          //onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          user: _user,
        ),
      ),
    );
  }
}

class Chats extends StatefulWidget {
  @override
  _Chats createState() => _Chats();
}

class _Chats extends State<Chats> {
  final _users = userDetails.users
      .map((usr) => MultiSelectItem<String>(usr, usr))
      .toList();

  var participants;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Message'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Select the people to add to conversation.'),
                MultiSelectDialogField(
                  items: _users,
                  listType: MultiSelectListType.LIST,
                  onConfirm: (values) {
                    participants=values;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => ChatMessages(Conversation(userDetails.firstName, participants)),
                    //  fullscreenDialog: true,
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          toolbarHeight: 80,
          title: Container(
            child: Container(
              // DefaultTextStyle: TextStyle(color: Colors.red),
              padding: EdgeInsets.only(top: 20),
              child: Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FlexColumnWidth(0.3),
                  1: FlexColumnWidth(0.7),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.top,

                children: <TableRow>[
                  TableRow(
                    children: <Widget>[
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.top,
                        child: Container(
                          height: 25,
                          //width: 32,
                          color: Colors.transparent,
                          child: IconButton(
                            color: Colors.black,
                            icon: const Icon(Icons.add),
                            tooltip: 'New',
                            onPressed: () async {
                              _showMyDialog();
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
        ),
        body: Consumer<Conversations>(builder: (context, data, _) {
          return ListView.separated(
            shrinkWrap: true,
            itemCount: conversations.conversations.length,
            itemBuilder: (context, index) {
              var element = conversations.conversations[index];
              return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => ChatMessages(element),
                        //  fullscreenDialog: true,
                      ),
                    );
                  },
                  title: Text(
                      conversations.conversations[index].targets.toString()));
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          );
        }));
  }
}

class Conversation {
  var id =  Uuid().v4();
  var source;
  var targets = [];
  var messages = [];

  Conversation(this.source, this.targets);




  Map<String, dynamic> toJson() => {
    'id': id,
    'author': source,
    'participants': targets,
    'messages': messages
  };
}



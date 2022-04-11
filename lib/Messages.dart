import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:alerts/Conversations.dart';
import 'package:alerts/LoginScreen.dart';
import 'package:alerts/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'PermissionCheck.dart';

class ChatMessages extends StatefulWidget {
  Conversation conversation;

  ChatMessages(this.conversation);

  @override
  _ChatMessages createState() => _ChatMessages(conversation);
}

class _ChatMessages extends State<ChatMessages> {
  Conversation conversation;

  _ChatMessages(this.conversation);

  /* void _loadMessages() async {
    setState(() {
      _messages = [for (var e in conversation.messages) e as types.Message];

      for (var i = 0; i < _messages.length; i++)
        _messages[i] = _messages[i].copyWith(status: types.Status.seen);
    });
  }*/

  final _user =
  types.User(id: userDetails.firstName!, firstName: userDetails.firstName!);

  @override
  void initState() {
    super.initState();
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
          author: _user,
          createdAt: DateTime
              .now()
              .millisecondsSinceEpoch,
          id: const Uuid().v4(),
          name: result.files.single.name,
          size: result.files.single.size,
          uri: result.files.single.path!,
          status: types.Status.sent);

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      var messageId = const Uuid().v4();

      final message = types.ImageMessage(
          author: _user,
          createdAt: DateTime
              .now()
              .millisecondsSinceEpoch,
          height: image.height.toDouble(),
          id: messageId,
          name: result.name,
          size: bytes.length,
          uri: protocol +
              '://' +
              serverAddress +
              port +
              '/api/chatAssets/' +
              messageId,
          width: image.width.toDouble(),
          roomId: conversation.id,
          status: types.Status.delivered);

      ChatImageUpload upload = ChatImageUpload();
      upload.messageId = messageId;
      upload.image = base64.encode(bytes);
      upload.filename = result.name;

      final response = await http.post(
        Uri.parse(protocol +
            '://' +
            serverAddress +
            port +
            '/api/conversation/uploadImage'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(upload),
      );

      _addMessage(message);
    }
  }

  void _handleSendPressed(types.PartialText message) {
    if (PermissionCheck.check(PermissionCheck.SEND_MESSAGE, context)) {
      final textMessage = types.TextMessage(
          author: _user,
          createdAt: DateTime
              .now()
              .millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: message.text,
          roomId: conversation.id,
          status: types.Status.delivered
        //repliedMessage: conversation.messages.length > 0 ? conversation.messages[conversation.messages.length-1].id : null
      );
//send this to the server.
      _addMessage(textMessage);
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.FileMessage) {
      await OpenFile.open(message.uri);
    }
  }

  void _handlePreviewDataFetched(types.TextMessage message,
      types.PreviewData previewData,) {
    final index =
    conversation.messages.indexWhere((element) => element.id == message.id);
    final updatedMessage =
    conversation.messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        conversation.messages[index] = updatedMessage;
      });
    });
  }

  void _addMessage(types.Message message) {
    conversation.messages.add(message);

    stompClient.send(
      destination: '/app/conversation/new',
      body: json.encode(conversation.toJson()),
    );

    setState(() {
      conversation.messages.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Boom we got here');

    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme
            .of(context)
            .iconTheme,
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
                        child: Text(
                            "Chatting to :" + conversation.targets.join(", "),
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyText2
                                ?.copyWith(
                                fontSize: 20,
                                color:
                                Theme
                                    .of(context)
                                    .colorScheme
                                    .primary)
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
          child: Consumer<Conversations>(builder: (context, data, _) {
            conversation = Provider
                .of<Conversations>(context)
                .conversations
                .where((element) => element.id == conversation.id)
                .first;

            print(conversation.id);
            conversations.updateStatus(conversation.id);
            //_messages.clear();
            //_messages.addAll(conversation.messages);

            //_messages.sort((a, b) => b.createdAt!.compareTo(a.createdAt!)) as List<types.Message>;

            return Chat(
              messages: conversation.messages,
              showUserNames: true,
              onAttachmentPressed: _handleAtachmentPressed,
              onMessageTap: _handleMessageTap,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              user: _user,
            );
          })),
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
                    participants = values;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                var conversation =
                Conversation(userDetails.firstName, participants);

                conversations.create(conversation);

                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        ChatMessages(conversation),
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
          iconTheme: Theme
              .of(context)
              .iconTheme,
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
                          child: Text(
                              "Groups ",
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(
                                  fontSize: 20,
                                  color:
                                  Theme
                                      .of(context)
                                      .colorScheme
                                      .primary)

                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.top,
                        child: Container(
                          height: 25,
                          alignment: Alignment.centerLeft,
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
        body: ListView.separated(
          shrinkWrap: true,
          itemCount: Provider
              .of<Conversations>(context)
              .conversations
              .length,
          itemBuilder: (context, index) {
            var element =
            Provider
                .of<Conversations>(context)
                .conversations[index];
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
                trailing:
                IconButton(
                  icon: const Icon(Icons.delete_outlined),
                  onPressed: () {
                    stompClient.send(
                      destination: '/app/conversation/delete',
                      body: json.encode(conversations.conversations[index].toJson()),
                    );
                  },
                ),
                title: Text(
            conversations.conversations[index].targets.join(", ") +
                (!conversations.conversations[index].messages.isEmpty
                    ? conversations
                    .conversations[index].messages[0].showStatus
                    .toString()
                    : " ")));
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
        ));
  }
}

class Conversation {
  var id = Uuid().v4();
  var source;
  var targets = [];
  List<types.Message> messages = [];
  var deleted;

  Conversation(this.source, this.targets);

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'author': source,
        'participants': targets,
        'messages': messages
      };
}

class ChatImageUpload {
  late String image;
  late String messageId;
  late String filename;

  Map<String, dynamic> toJson() =>
      {'image': image, 'messageId': messageId, 'filename': filename};
}

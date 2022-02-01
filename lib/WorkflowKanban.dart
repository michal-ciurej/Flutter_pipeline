import 'dart:convert';

import 'package:alerts/Cases.dart';
import 'package:alerts/main.dart';
import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview_controller.dart';
import 'package:boardview/boardview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';

import 'CasesScreen.dart';

class WorkflowKanban extends StatefulWidget {
  StompClient client;

  WorkflowKanban({required this.client});

  @override
  _WorkflowKanban createState() => _WorkflowKanban(client);
}

class _WorkflowKanban extends State<WorkflowKanban> {
  StompClient client;

  _WorkflowKanban(this.client);

  List<BoardItemObject> _items = [];

  final List<BoardListObject> _listData = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<Cases>(builder: (context, data, _) {
      //create each case
      _items.clear();
      data.cases.forEach((ticket) {
        _items.add(BoardItemObject(
            title: ticket.description,
            status: ticket.status,
            id: ticket.id.toString(),
            site: ticket.site,
            dueDate: ticket.date,
            assignee: ticket.assignee));
      });

      //add cases to columns
      _listData.clear();
      data.workflowSteps.forEach((step) {
        var col = BoardListObject(title: step);
        col.items!
            .addAll(_items.where((ticket) => ticket.status == step).toList());

        _listData.add(col);
      });

      BoardViewController boardViewController = new BoardViewController();
      List<BoardList> _lists = <BoardList>[];
      for (int i = 0; i < _listData.length; i++) {
        _lists.add(_createBoardList(_listData[i]) as BoardList);
      }
      return Column(children: [
        //Row(children:[KanBanControls()]),
        SizedBox(
            height: 500,
            child: BoardView(
              lists: _lists,
              boardViewController: boardViewController,
            ))
      ]);
    });
  }

  Widget buildBoardItem(BoardItemObject itemObject) {
    return BoardItem(
        onStartDragItem:
            (int? listIndex, int? itemIndex, BoardItemState? state) {
          print('should be dragging');
        },
        onDropItem: (int? listIndex, int? itemIndex, int? oldListIndex,
            int? oldItemIndex, BoardItemState? state) {
          //Used to update our local item data
          print(_listData[oldListIndex!].title.toString() +
              " to " +
              _listData[listIndex!].title.toString());

          var item = _listData[oldListIndex!].items![oldItemIndex!];

          _listData[oldListIndex].items!.removeAt(oldItemIndex!);
          _listData[listIndex!].items!.insert(itemIndex!, item);

          var toUpdate = cases.cases
              .firstWhere((element) => element.id.toString() == item.id);

          TicketModel ticket = new TicketModel();
          ticket.id = toUpdate.id;
          ticket.date = toUpdate.date;
          ticket.assignee = toUpdate.assignee;
          ticket.status = _listData[listIndex!].title;

          client.send(
              destination: '/app/updateTicket',
              body: jsonEncode(ticket.toJson()));
        },
        onTapItem:
            (int? listIndex, int? itemIndex, BoardItemState? state) async {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  CaseDetailView(id: itemObject.id, stompClient: client),
              fullscreenDialog: false,
            ),
          );
        },
        item: Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Summary: " + itemObject.title!),
              Text("Assignee: " + itemObject.assignee!),
            ]),
          ),
          Container(
              //alignment: Alignment.bottomRight,
              height: 50,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    Text(itemObject.site!.substring(0, 3).toUpperCase() +
                        '-' +
                        itemObject.id!),
                    if (DateTime.now()
                        .isAfter(DateTime.parse(itemObject.dueDate!))) ...[
                      Icon(
                        Icons.query_builder_outlined,
                        color: Colors.red,
                      ),
                    ],
                    Spacer(flex: 3),
                    Text(itemObject.site!),
                    Image.network(protocol +
                        '://' +
                        serverAddress +
                         port + '/api/static/' +
                        sites.sites
                            .firstWhere(
                                (element) => itemObject.site == element.name)
                            .imageName),
                  ])))
        ])));
  }

  Widget _createBoardList(BoardListObject list) {
    List<BoardItem> items = [];
    for (int i = 0; i < list.items!.length; i++) {
      items.insert(i, buildBoardItem(list.items![i]) as BoardItem);
    }

    return BoardList(
      onStartDragList: (int? listIndex) {},
      onTapList: (int? listIndex) async {},
      onDropList: (int? listIndex, int? oldListIndex) {
        //Update our local list data
        var list = _listData[oldListIndex!];
        _listData.removeAt(oldListIndex!);
        _listData.insert(listIndex!, list);
      },
      headerBackgroundColor: Color.fromARGB(255, 235, 236, 240),
      backgroundColor: Color.fromARGB(255, 235, 236, 240),
      header: [
        Container(
            child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  list.title!,
                  style: TextStyle(fontSize: 20),
                ))),
      ],
      items: items,
    );
  }
}

class KanBanControls extends StatefulWidget {
  @override
  _KanBanControls createState() => _KanBanControls();
}

class _KanBanControls extends State<KanBanControls> {
  var isFilterSwitched = false;
  var searchString = "";

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchString = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            labelText: 'Search',
            suffixIcon: Icon(Icons.search),
          ),
        ),
      ),
      Expanded(
          child: SwitchListTile(
        title: const Text('All / Un-Cleared Alerts'),
        value: isFilterSwitched,
        onChanged: (bool value) {
          setState(() {
            isFilterSwitched = value;
          });
        },
        secondary: const Icon(Icons.warning_amber),
      ))
    ]);
  }


}

class BoardItemObject {
  String? title;
  String? status;
  String? site;
  String? id;
  String? assignee;
  String? dueDate;

  BoardItemObject(
      {this.title,
      this.status,
      this.id,
      this.site,
      this.assignee,
      required this.dueDate}) {
    if (this.title == null) {
      this.title = "";
    }
  }
}

class BoardListObject {
  String? title;
  List<BoardItemObject>? items;

  BoardListObject({this.title, this.items}) {
    if (this.title == null) {
      this.title = "";
    }
    if (this.items == null) {
      this.items = [];
    }
  }
}

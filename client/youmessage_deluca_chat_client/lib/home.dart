import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uMessage/chat.dart';
import 'package:uMessage/contact_selector.dart';
import 'dart:async';

final List<ChatOfList> _chats = <ChatOfList>[];
String myId="User ID:";
class Home extends StatefulWidget {
  @override
  State createState() => new ChatsList();
}

class ChatsList extends State<Home> with TickerProviderStateMixin {
  ChatsList() {
    //convertBackupToChats();
    loadId();
  }
  loadId()async{
    final prefs = await SharedPreferences.getInstance();
    myId=prefs.getString("id");
    setState(() {
      
    });
  }
  Future convertBackupToChats() async {
    List<String> _chatsBackup = [];

    final prefs = await SharedPreferences.getInstance();
    _chatsBackup = prefs.getStringList("chats");
    _chats.clear();
    if (_chatsBackup != null)
      _chatsBackup.asMap().forEach((index, value) {
        ChatOfList chat = new ChatOfList();
        if ((index % 3) == 0) chat.nameString = value;
        if ((index % 3) == 1) chat.desc = value;
        if ((index % 3) == 2) chat.chatId = value;
        _chats.add(chat);
      });
  }

  Future convertChatsToBackup() async {
    List<String> _chatsBackup = new List<String>();
    final prefs = await SharedPreferences.getInstance();
    _chats.forEach((c) {
      _chatsBackup.add(c.nameString);
      _chatsBackup.add(c.desc);
      _chatsBackup.add(c.chatId);
    });
    prefs.setStringList("chats", _chatsBackup);
  }

  String alertName, alertDesc, alertId;

  Future<String> _asyncInputDialog(BuildContext context) async {
    return showDialog<String>(
        context: context,
        barrierDismissible:
            false, // dialog is dismissible with a tap on the barrier
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('new chat'),
            content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'user or group chat name', hintText: 'eg. peppiniello87'),
                  onChanged: (value) {
                    alertId = value;
                  },
                ),
                new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'Description', hintText: 'eg. Pizzaiolo'),
                  onChanged: (value) {
                    alertDesc = value;
                  },
                ),
                new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'Chat Name', hintText: 'eg. El Peppi'),
                  onChanged: (value) {
                    alertName = value;
                  },
                ),
              ],
            ),),
            actions: <Widget>[
              FlatButton(
                child: Text('Add'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _chats.add(ChatOfList(
                      nameString: alertName,
                      desc: alertDesc,
                      animationController: new AnimationController(
                          vsync: this,
                          duration: new Duration(milliseconds: 800)),
                      chatId: alertId));
                  setState(() {
                    print("weee update");
                  });
                  //convertChatsToBackup();
                },
              ),
            ],
          );
        });
  }
  @override
  Widget build(BuildContext ctx) {
    TickerProvider contex = this;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("uMessage by DelU"),
        elevation: Theme.of(ctx).platform == TargetPlatform.iOS ? 0.0 : 6.0,
        actions: <Widget>[
          Icon(
            Icons.cloud,
            color: Colors.green,
          ),
          IconButton(
            icon: Icon(
              Icons.contacts,
            ),
            onPressed: () async {
              final ris = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactSelector()),
              );
              if(ris!=null)_chats.add(ChatOfList(chatId: ris[0],nameString: ris[0],desc: "chat with "+ris[0]));
            },
          ),
          IconButton(
              icon: Icon(
                Icons.add,
              ),
              onPressed: () {
                _asyncInputDialog(ctx);
                setState() {};
              }),
        ],
      ),
      body: new Column(children: <Widget>[
        new ChatOfList(
            nameString: "CHATROOM - GLOBAL",
            desc: "Chatroom - click to enter",
            animationController: new AnimationController(
                vsync: this, duration: new Duration(milliseconds: 800)),
            chatId: "global")
          ..animationController.forward(),
        new Flexible(
          child: new ListView.builder(
            itemBuilder: (BuildContext ctxt, int index) {
              return new ChatOfList(
                  nameString: (_chats[index].nameString != null)
                      ? _chats[index].nameString.toUpperCase()
                      : " ",
                  desc: (_chats[index].desc != null &&
                          _chats[index].desc.length > 40)
                      ? (_chats[index].desc.substring(0, 40) + "...")
                      : _chats[index].desc,
                  animationController: new AnimationController(
                      vsync: this, duration: new Duration(milliseconds: 800)),
                  chatId: _chats[index].chatId)
                ..animationController.forward();
            },
            itemCount: _chats.length,
            reverse: false,
            padding: new EdgeInsets.all(6.0),
          ),
        ),
        new Text("User ID: " + myId,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
        new Divider(height: 1.0),
        new Container(
          child: _buildComposer(),
          decoration: new BoxDecoration(color: Theme.of(ctx).cardColor),
        ),
      ]),
    );
  }

  Widget _buildComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 9.0),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border: new Border(top: new BorderSide(color: Colors.brown)))
              : null),
    );
  }

  @override
  void dispose() {
    for (ChatOfList cht in _chats) {
      cht.animationController.dispose();
    }
    super.dispose();
  }
}

class ChatOfList extends StatelessWidget {
  ChatOfList(
      {this.nameString = " ",
      this.desc = " ",
      this.animationController,
      this.chatId});
  String desc = " ";
  String nameString = " ";
  final AnimationController animationController;
  String chatId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Widget build(BuildContext ctx) {
    return new SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: () {
            if (chatId == null || chatId.isEmpty) chatId = nameString;
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (context) => Chat(chatId)),
            );
          },
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(right: 8.0, left: 15.0),
                child: new CircleAvatar(
                    child: new Text(nameString[0]), radius: 40),
              ),
              new Expanded(
                child: new Container(
                  padding: new EdgeInsets.only(top: 10.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text((nameString == null) ? " " : nameString,
                          style: TextStyle(fontSize: 25.0)),
                      new Container(
                        margin: const EdgeInsets.only(top: 6.0),
                        child: new Text(desc.toString()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

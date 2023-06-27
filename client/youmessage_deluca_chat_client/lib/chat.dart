import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

String chatName;

class Chat extends StatefulWidget {
  String chatId;
  Chat(this.chatId) {
    chatName = chatId;
  }
  @override
  State createState() => new ChatWindow(chatId);
}

class ChatWindow extends State<Chat> with TickerProviderStateMixin {
  Socket socket;
  String idChat;
  bool connected = true;
  final List<Msg> _messages = <Msg>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;

  ChatWindow(this.idChat) {
    connect(idChat);
  }

  void connect(idChat) async {
    final prefs = await SharedPreferences.getInstance();
    await Socket.connect("deluca.pro", 1010).then((Socket sock) {
      socket = sock;
      socket.listen(dataHandler,
          onError: errorHandler, onDone: doneHandler, cancelOnError: false);
      socket.write("?clientid:" + prefs.getString("id"));
      socket.write("?chatwith:" + idChat);
      connected = true;
    }).catchError((Object e) {
      print("Unable to connect: $e");
    });
  }

  Future dataHandler(data) async {
    EmojiParser parser = new EmojiParser();
    String msgR = parser.emojify(String.fromCharCodes(data).trim());
    print("data handler" + msgR);
    int sepIndex1 = -1, sepIndex2 = -1;
    for (int i = 0; i < msgR.length && sepIndex2 == -1; i++) {
      if (msgR[i] == ':') {
        if (sepIndex1 == -1)
          sepIndex1 = i;
        else
          sepIndex2 = i;
      }
    }
    if (sepIndex1 == -1) {
      sepIndex1 = 0;
      sepIndex2 = 0;
    }
    int msgTime = int.parse(msgR.trim().substring(0, sepIndex1));
    String msgOrigin = msgR.substring(sepIndex1 + 1, sepIndex2);
    String msgText = msgR.substring(sepIndex2 + 1);
    final prefs = await SharedPreferences.getInstance();
    bool rightSide = false;
    if (msgOrigin == prefs.getString("id")) rightSide = true;
    Msg msg = new Msg(
      nameString: msgOrigin,
      txt: msgText,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
      rightSide: rightSide,
    );

    setState(
      () {
        _messages.insert(0, msg);
      },
    );
    msg.animationController.forward();
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void doneHandler() {
    socket.destroy();
    connected = false;
    infoWrite("Server disconnected");
  }

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(chatName + " on uMessage"),
        elevation: Theme.of(ctx).platform == TargetPlatform.iOS ? 0.0 : 6.0,
        actions: <Widget>[
          InkWell(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              infoWrite("Reconnecting...");
              await Socket.connect("deluca.pro", 1010).then((Socket sock) {
                socket = sock;
                socket.listen(dataHandler,
                    onError: errorHandler,
                    onDone: doneHandler,
                    cancelOnError: false);
                socket.write("?clientid:" + prefs.getString("id"));
                socket.write("?chatwith:" + idChat);
                connected = true;
              }).catchError((Object e) {
                print("Unable to connect: $e");
              });
            },
            child: Icon((connected) ? Icons.cloud : Icons.refresh,
                color: (connected) ? Colors.green : Colors.redAccent),
          ),
        ],
      ),
      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new ListView.builder(
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
              reverse: true,
              padding: new EdgeInsets.all(6.0),
            ),
          ),
          new Divider(height: 1.0),
          new Container(
            child: _buildComposer(),
            decoration: new BoxDecoration(color: Theme.of(ctx).cardColor),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 9.0),
          child: new Row(
            children: <Widget>[
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  onChanged: (String txt) {
                    setState(
                      () {
                        _isWriting = txt.length > 0;
                      },
                    );
                  },
                  onSubmitted: _submitMsg,
                  decoration: new InputDecoration.collapsed(
                      hintText: "Type a message..."),
                ),
              ),
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 3.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoButton(
                        child: new Text("Submit"),
                        onPressed: _isWriting
                            ? () => _submitMsg(_textController.text)
                            : null)
                    : new IconButton(
                        icon: new Icon(Icons.message),
                        onPressed: _isWriting
                            ? () => _submitMsg(_textController.text)
                            : null,
                      ),
              ),
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border: new Border(top: new BorderSide(color: Colors.brown)))
              : null),
    );
  }

  void infoWrite(String txt) {
    _textController.clear();
    setState(
      () {
        _isWriting = false;
      },
    );
    Msg msg = new Msg(
      nameString: "Bobby the bot",
      txt: "INFO: " + txt,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
      rightSide: false,
    );
    setState(
      () {
        _messages.insert(0, msg);
      },
    );
    msg.animationController.forward();
  }

  Future _submitMsg(String txt) async {
    EmojiParser parser = new EmojiParser();
    _textController.clear();
    setState(
      () {
        _isWriting = false;
      },
    );
    socket.write(idChat + ":" + parser.unemojify(txt));
  }

  @override
  void dispose() {
    for (Msg msg in _messages) {
      msg.animationController.dispose();
    }
    super.dispose();
    socket.destroy();
  }
}

class Msg extends StatelessWidget {
  Msg(
      {this.nameString,
      this.txt,
      this.animationController,
      this.rightSide = false});
  final String txt;
  final String nameString;
  bool rightSide = true;
  final AnimationController animationController;

  @override
  Widget build(BuildContext ctx) {
    if (rightSide) {
      return new SizeTransition(
        sizeFactor: new CurvedAnimation(
            parent: animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Text(nameString,
                        style: Theme.of(ctx).textTheme.subhead),
                    new Container(
                      margin: const EdgeInsets.only(top: 6.0),
                      child: new Text(txt),
                    ),
                  ],
                ),
              ),
              new Container(
                margin: const EdgeInsets.only(left: 8.0),
                child: new CircleAvatar(child: new Text(nameString[0])),
              )
            ],
          ),
        ),
      );
    } else {
      return new SizeTransition(
        sizeFactor: new CurvedAnimation(
            parent: animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: new CircleAvatar(child: new Text(nameString[0])),
              ),
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(nameString,
                        style: Theme.of(ctx).textTheme.subhead),
                    new Container(
                      margin: const EdgeInsets.only(top: 6.0),
                      child: new Text(txt),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

import 'dart:io';

ServerSocket server;
List<ChatClient> clients = [];
List<Chat> chats = [];

void main() {
  print("Server ready");
  ServerSocket.bind(InternetAddress.anyIPv4, 1010).then((ServerSocket socket) {
    server = socket;
    server.listen((client) {
      handleConnection(client);
    });
    ChatClient globalClient = ChatClient.fromId("Global");
    clients.add(globalClient);
    Chat global = Chat([globalClient], isGroupChat: true);
    chats.add(global);
  });
}

void handleConnection(Socket client) {
  print('Connection from ${client.remoteAddress.address}:${client.remotePort}');

  clients.add(ChatClient(client));

  // client.write("Welcome to dart-chat! "
  //     "There are ${clients.length - 1} other clients\n");
}

void removeClient(ChatClient client) {
  clients.remove(client);
}

void distributeMessage(ChatClient client, String message) {
  for (ChatClient c in clients) {
    if (c != client) {
      c.write(message + "\n");
    }
  }
}

// ChatClient class for server

class ChatClient {
  Socket _socket;
  String get _address => _socket.remoteAddress.address;
  int get _port => _socket.remotePort;
  String clientId;
  Chat currentChat;

  ChatClient(Socket s) {
    _socket = s;
    _socket.listen(messageHandler,
        onError: errorHandler, onDone: finishedHandler);
  }
  ChatClient.fromId(this.clientId) {}

  int findSeparator(String s) {
    int sepIndex = -1;
    for (int i = 0; i < s.length && sepIndex == -1; i++) {
      if (s[i] == ':') sepIndex = i;
    }
    return sepIndex;
  }

  void messageHandler(data) {
    String message = new String.fromCharCodes(data).trim(), destination, msg;
    if (message[0] == '?') {
      //server command
      int separator =
          findSeparator(message); //separator between cmd and param index
      String cmd = message.substring(1, separator);
      String param = message.substring(separator + 1);
      switch (cmd) {
        case "clientid":
          clientId = param;
          print(_socket.address.toString() + " nickname= " + clientId);
          break;
        case "chatwith":
          print(clientId + " joined " + param);
          currentChat = connectToChat(chatClientFromClientId(param));
          if (!currentChat.clients.contains(this))
            currentChat.clients.add(this);
          List<String> clientsConnected = [];
          try {
            currentChat.clients.forEach((client) {
              //deleting disconnected clients
              if (!clients.contains(client))
                currentChat.clients.remove(client);
              else
                clientsConnected.add(client.clientId);
            });
          } catch (e) {}
          int len = clientsConnected.toSet().toList().length;
          String clientsDistinct = clientsConnected
              .toSet()
              .toList()
              .toString()
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll("Global", "Server");
          if (currentChat.isGroupChat) {
            this.write((new DateTime.now().millisecondsSinceEpoch).toString() +
                ":Server:Hi, " +
                len.toString() +
                "clients connected\n" +
                "Clients: " +
                clientsDistinct);
          }
          break;
        default:
          print("Error command parsing");
      }
    } else {
      //message handling
      int separator =
          findSeparator(message); //separator between cmd and param index
      destination = message.substring(0, separator);
      msg = message.substring(separator + 1);
      //print(clientId + " sending msg to " + destination); //debug
      print(clientId + " sending msg " + msg); //debug
      forwardMessage(destination, msg);
      //distributeMessage(this, '${_address}:${_port} Message: $message');
    }
  }

  void forwardMessage(String destinationId, String msg) {
    Chat currentChat = connectToChat(chatClientFromClientId(destinationId));
    currentChat.messages.add(
        (new DateTime.now().millisecondsSinceEpoch).toString() +
            ":" +
            clientId +
            ":" +
            msg);
    for (ChatClient c in currentChat.clients) {
      //print(c.clientId+"^^^"); //debug
      if (c != null && clients.contains(c) && c.clientId != "global")
        c.write((new DateTime.now().millisecondsSinceEpoch).toString() +
            ":" +
            clientId +
            ":" +
            msg);
    }
  }

  Chat connectToChat(ChatClient b) {
    Chat ris = null;
    chats.forEach((chat) => {
          if (chat.clients.contains(b)) {ris = chat}
        });
    if (ris == null) {
      //group chat detector
      chats.forEach((chat) => {
            chat.clients.forEach((client) => {
                  if (client.clientId.toLowerCase() == b.clientId.toLowerCase())
                    {ris = chat}
                })
          });
    }
    if (ris == null) {
      Chat newChat = Chat([this, b]);
      chats.add(newChat);
      return newChat;
    } else {
      return ris;
    }
  }

  ChatClient chatClientFromClientId(String clientId) {
    ChatClient ris = null;
    clients.forEach((client) => {
          if (client.clientId == clientId) {ris = client}
        });
    if (ris == null) {
      ChatClient newCC = ChatClient.fromId(clientId);
      return newCC;
    } else
      return ris;
  }

  void errorHandler(error) {
    print('${_address}:${_port} Error: $error');
    try {
      removeClient(this);
      _socket.close();
    } catch (e) {}
  }

  void finishedHandler() {
    print('${_address}:${_port} Disconnected');
    removeClient(this);
    _socket.close();
  }

  void write(String message) {
    try {
      _socket.write(message);
    } catch (e) {}
  }
}

class Chat {
  static int progressiveId = 0;
  int id = ++progressiveId;
  List<ChatClient> clients;
  List<String> messages = [];
  bool isGroupChat = false;
  Chat(List<ChatClient> this.clients, {this.isGroupChat = false});
}

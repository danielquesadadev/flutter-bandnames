import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;

  get serverStatus => _serverStatus;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    // Dart client
    IO.Socket socket = IO.io('http://192.168.68.56:3000/', {
      'transports': ['websocket'],
      'autoConnect': true
    });
    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    socket.on('event', (data) => print(data));
    socket.onDisconnect((_) => {_serverStatus = ServerStatus.Offline});
    socket.on('fromServer', (_) => print(_));
  }
}

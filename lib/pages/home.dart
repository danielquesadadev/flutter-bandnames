import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/services/socket_service.dart';
import 'package:band_names/models/band.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    /* Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'ACDC', votes: 5),
    Band(id: '3', name: 'Estopa', votes: 5),
    Band(id: '4', name: 'Bad bunny', votes: 5), */
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', (payload) {
      this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    });
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grupos de música',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : Icon(
                    Icons.offline_bolt,
                    color: Colors.red[900],
                  ),
          )
        ],
      ),
      body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, i) => _bandTile(bands[i])),
      floatingActionButton: FloatingActionButton(
          onPressed: () => addNewBand(), elevation: 1, child: Icon(Icons.add)),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        //TODO: Eliminar de ddbb
        print('id: ${band.id}');
      },
      background: Container(
        padding: EdgeInsets.only(left: 12),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Eliminar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          socketService.emit(('emit-band'), {'id': band.id});
        },
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Añadir nueva banda'),
                content: TextField(
                  controller: textController,
                  autofocus: true,
                ),
                actions: <Widget>[
                  MaterialButton(
                    child: Text('Añadir'),
                    elevation: 5,
                    textColor: Colors.blue,
                    onPressed: () => addBandToList(textController.text),
                  )
                ],
              ));
    } else {
      return showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text('Añadir nueva banda'),
              content: CupertinoTextField(
                autofocus: true,
                controller: textController,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Add'),
                  onPressed: () => addBandToList(textController.text),
                ),
              ],
            );
          });
    }
  }

  void addBandToList(String nameBand) {
    print(nameBand);
    if (nameBand.length > 1) {
      //podemos add
      this.bands.add(
          new Band(id: DateTime.now().toString(), name: nameBand, votes: 0));
      setState(() {});
    }
    Navigator.pop(context);
  }
}

// ignore_for_file: avoid_print

import 'dart:async';
import 'package:dizzbase_demo/dizzbase_client/dizzbase_transactions.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:uuid/uuid.dart';
import 'dizzbase_query.dart';

class DizzbaseRequest
{
  Map<String, dynamic> toJson() 
  {
    throw Exception("Abstract base class toJson called in DizzbaseRequest.");
  }
}

class DizzbaseConnection
{
  final String url = "http://localhost:3000";
  late String connectionuuid;
  late io.Socket _socket;
  StreamController<List<Map<String,dynamic>>>? _controller;
  Map<String, DizzbaseTransaction> transactions = {};

  DizzbaseConnection ()
  {
    connectionuuid = const Uuid().v4();
    _socket = io.io(url);
    _socket.emit ('init', connectionuuid);

    _socket.onConnect((val) {
      // Moved the init event directly after the io.io(url) call as the .onConnect event wasn't triggered reliably 
      //_socket.emit ('init', connectionuuid);
      print('Connected to server.');
    });

    // Send from server on query transactions (eg SELECT)
    _socket.on('data', (data) {
      try
      {
        if (data['status']['uuid'] == connectionuuid && data['status']['type'] == 'dizzbasequery')
        {
          if ((data['status']['error'] != '') || (data['data'] == null))
          {
            print ("ERROR on query: ${data['status']}");
          } else {
            _sendToStream(convertList (data['data']));
          }
        }
      } catch (e) {print ("_socket.on ('data') - error: $e");}
    }); 

    // Send from server on non-query transactions (eg INSERT/DELETE/UPDATE)
    _socket.on('status', (data) {
      if (data['uuid'] == connectionuuid)
      {
        print ("STATUS: $data");
        var insertedKeys = convertList (data['rows']);
        transactions[data['transactionuuid']]!.completer!.complete(insertedKeys[0]);
      }
    }); 

    _socket.onDisconnect((_) => print('disconnect'));
  }

  void dispose ()
  {
    _socket.emit('close', connectionuuid);
  }

  void _sendToStream(dynamic data)
  {
    if (_controller != null)
    {
      _controller!.add(data);
    }
  }

  void _sendToServer (DizzbaseRequest r)
  {
    var augmentedRequest = r.toJson();
    augmentedRequest['uuid'] = connectionuuid;
    augmentedRequest['type'] = r.runtimeType.toString().toLowerCase();

    _socket.emit('dbrequest', augmentedRequest);
  }

  Stream<List<Map<String,dynamic>>> sendQuery (DizzbaseQuery q)
  {
    _controller ??= StreamController<List<Map<String,dynamic>>>();
    _sendToServer(q);
    return _controller!.stream;
  }

  Future<Map<String, dynamic>> transaction (DizzbaseTransaction req)
  {
    if (req.isRunning())
    {
      throw Exception ("DizzbaseTransactions cannote be re-used before the previous transaction has been completed.");
    }

    req.init();
    transactions[req.transactionuuid] = req;
    _sendToServer(req);
    return req.completer!.future;
  }
}

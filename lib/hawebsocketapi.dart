import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HAWebsocketAPI {
  String host;
  String port;
  String token;

  HAWebsocketAPI(this.host, this.port, this.token);

  Uri _getUri() {
    return Uri.parse("ws://$host:$port/api/websocket");
  }

  Future<void> ping() async {
    Uri uri = _getUri();
    WebSocketChannel channel = WebSocketChannel.connect(uri);
    Map<String, String> auth = {
      "type": "auth",
      "access_token":
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI4ZDcwMTQ5OWI0ZTE0MjRjYTAwMTgyM2M0NzhmYTM4ZSIsImlhdCI6MTY4Nzc0ODkzMCwiZXhwIjoyMDAzMTA4OTMwfQ.DysYrHswdLD9pyR9D1xJzNMY2LXxoyXyf4tgVsKVjE0"
    };
    String authJson = jsonEncode(auth);
    channel.sink.add(authJson);
    /*
    
    const pingMsg = {"id": 19, "type": "pong"};
    channel.sink.add(pingMsg);
    */
    channel.stream.listen((message) {
      Map<String, dynamic> msg = jsonDecode(message);
      debugPrint(message);
      String msgType = msg['type'].toString();
      if (msgType == "auth_ok") {
        Map<String, dynamic> pingMsg = {"type": "ping", "id": 19};
        String pingMsgJson = jsonEncode(pingMsg);
        channel.sink.add(pingMsgJson);

        Map<String, dynamic> talk = {
          "type": "assist_pipeline/run",
          "start_stage": "intent",
          "input": {"text": "what is scoresby temp"},
          "end_stage": "intent",
          "conversation_id": null,
          "id": 40
        };

        String talkJson = jsonEncode(talk);
        channel.sink.add(talkJson);
      }
      //debugPrint(msgType);

      //channel.sink.close(WebSocketStatus.normalClosure);
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  /*
  Future<bool> ping(String haUrl, String token) async {
    var url = Uri.parse("$haUrl/api/");
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<String> talkToHA(String haUrl, String token, String message) async {
    var url = Uri.parse("$haUrl/api/services/conversation/process");
    var response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"text": message}));
    return response.body;
  }
  */
}

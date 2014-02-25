library simple_dart_chat.server;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:route/server.dart' show Router;
import './../common/common.dart';

/**
 * Class [Server] implement simple server chat
 */
class Server {
  /**
   * Server bing port
   */
  int port;
  
  /**
   * Server address
   */
  var address;
  
  /**
   * Current server
   */
  HttpServer _server;
  
  /**
   * Router
   */
  Router _router;
  
  /**
   * Active connections
   */
  Map<String, WebSocket> connections = new Map<String, WebSocket>();
  
  int generalCount = 1;
  
  /**
   * Server constructor
   * param [address]
   * param [port]
   */
  Server([
    this.address = '127.0.0.1', 
    this.port = 9223
  ]);
  
  /**
   * Bind the server
   */
  bind() {
    HttpServer.bind(address, port).then(connectServer);
  }
  
  /**
   * Callback when server is ready
   */
  connectServer(server) {
    print('Chat server is running on "$address:$port"');
    
    _server = server;
    bindRouter();
  }
  
  /**
   * Bind routes
   */
  bindRouter() {
    _router = new Router(_server);
    
    _router.serve('/')
      .transform(new WebSocketTransformer())
      .listen(this.listenWs);
  }
  
  listenWs(WebSocket webSocket) {
    String connectionName = 'user_$generalCount';
    generalCount++;
    
    connections.putIfAbsent(connectionName, () => webSocket);
    
    webSocket
      .map((string) => JSON.decode(string))
      .listen((json) {
        if (json['cmd'] == CMD_INIT_CLIENT) {
          sendNick(connectionName);
          notifyAbout(connectionName, '$connectionName joined the chat');
        } else if (json['cmd'] == CMD_SEND_MESSAGE) {
          sendMessage(json['from'], json['message']);
        }
      }).onDone(() {
        closeConnection(connectionName);
        notifyAbout(connectionName, '$connectionName logs out chat');
      });
  }
  
  /**
   * Sending message to all client
   */
  sendMessage(String from, String message) {
    String jdata = buildMessage(CMD_SEND_MESSAGE, from, message);
    connections.forEach((username, conn) {
      conn.add(jdata);
    });
  }
  
  /**
   * Send nick to new client
   */
  sendNick(String connectionName) {
    String jdata = buildMessage(CMD_INIT_CLIENT, SYSTEM_CLIENT, connectionName);
    
    if (connections.containsKey(connectionName)) {
      connections[connectionName].add(jdata);
    }    
  }
  
  /**
   * Notify all users about new connection
   */
  notifyAbout(String connectionName, String message) {
    String jdata = buildMessage(CMD_SEND_MESSAGE, SYSTEM_CLIENT, message);
    
    connections.forEach((username, conn) {
      if (username != connectionName) {
        conn.add(jdata);
      }
    });
  }
  
  /**
   * Build message
   */
  String buildMessage(String cmd, String from, String message) {
    Map<String, String> data = {
      'cmd': cmd,
      'from': from,
      'message': message,
      'online': connections.length
    };
    
    return JSON.encode(data);
  }
  
  /**
   * Close user connections
   */
  closeConnection(String connectionName) {
    if (connections.containsKey(connectionName)) {
      connections.remove(connectionName);
    }
  }
  
}

main() {
  Server server = new Server(ADDRESS, PORT);
  server.bind();
}

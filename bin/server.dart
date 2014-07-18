part of simplechat.bin;

/**
 * Class [Server] implement simple chat server
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
    this.port = 9224
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
      .listen(this.createWs);
  }

  createWs(WebSocket webSocket) {
    String connectionName = 'user_$generalCount';
    ++generalCount;
    
    connections.putIfAbsent(connectionName, () => webSocket);
    notifyAbout(connectionName, '$connectionName joined the chat');
    sendWelcome(connectionName);
    
    webSocket
      .map((string) => JSON.decode(string))
      .listen((json) {
        sendMessage(connectionName, json['message']);
      }).onDone(() {
        closeConnection(connectionName);
        notifyAbout(connectionName, '$connectionName logs out chat');
      });
  }
  
  /**
   * Sending message to all client
   */
  sendMessage(String from, String message) {
    String jdata = buildMessage(from, message);
    
    // search users that the message is intended
    RegExp usersReg = new RegExp(r"@([\w|\d]+)");
    Iterable<Match> users = usersReg.allMatches(message);
    
    // if users found - send message only them
    if (users.isNotEmpty) {
      users.forEach((Match match) {
        String user = match.group(0).replaceFirst('@', '');
        if (connections.containsKey(user)) {
          send(user, jdata);
        }
      });
      send(from, jdata);
    } else {
      connections.forEach((username, conn) {
        conn.add(jdata);
      });
    }
  }

  /**
   * Notify users
   */
  notifyAbout(String connectionName, String message) {
    String jdata = buildMessage(SYSTEM_CLIENT, message);

    connections.keys
      .where((String name) => name != connectionName)
      .forEach((String name) {
        send(name, jdata);
      });
  }

  /**
   * Sending welcome message to new client
   */
  void sendWelcome(String connectionName) {
    String jdata = buildMessage(SYSTEM_CLIENT, 'Welcome to chat!');

    send(connectionName, jdata);
  }

  /**
   * Sending message
   */
  void send(String to, String message) {
    connections[to].add(message);
  }
  
  /**
   * Build message
   */
  String buildMessage(String from, String message) {
    Map<String, String> data = {
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

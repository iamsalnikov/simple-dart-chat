library simple_dart_chat.client;

import './controllers/web_socket_controller.dart';

main() {
  WebSocketController wsc = new WebSocketController('ws://127.0.0.1:9223', '#messages', '#userText .text');   
}
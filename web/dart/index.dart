library simple_dart_chat.client;

import './controllers/web_socket_controller.dart';
import './../../common/common.dart';

main() {
  WebSocketController wsc = new WebSocketController('ws://$ADDRESS:$PORT', '#messages', '#userText .text', '#online');   
}
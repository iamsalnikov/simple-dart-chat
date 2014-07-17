library simplechat.client;

import "dart:html";
import 'dart:convert';
import './../../common/common.dart';

part './views/message_view.dart';
part './controllers/web_socket_controller.dart';


main() {
  WebSocketController wsc = new WebSocketController('ws://$ADDRESS:$PORT', '#messages', '#userText .text', '#online');   
}
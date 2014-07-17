library simple_dart_chat.client.controllers;

import 'dart:html';
import 'dart:convert';
import './../views/message_view.dart';
import './../../../common/common.dart';

class WebSocketController {  
  WebSocket ws;
  HtmlElement output;
  TextAreaElement userInput;
  DivElement online;
  
  WebSocketController(String connectTo, String outputSelector, String inputSelector, String onlineSelector) {
    output = querySelector(outputSelector);
    userInput = querySelector(inputSelector);
    online = querySelector(onlineSelector);
    
    ws = new WebSocket(connectTo);
    
    ws.onOpen.listen((e){
      showMessage('Сonnection is established', SYSTEM_CLIENT);
      bindSending();
    });
    
    ws.onClose.listen((e) {
      showMessage('Connection closed', SYSTEM_CLIENT);
    });
    
    ws.onMessage.listen((MessageEvent e) {
      processMessage(e.data);
    });
    
    ws.onError.listen((e) {
      showMessage('Connection error', SYSTEM_CLIENT);
    });
  }
  
  processMessage(String message) {
    var data = JSON.decode(message);
    
    showOnline(data['online']);
    showMessage(data['message'], data['from']);
  }
  
  bindSending() {
    userInput.onKeyUp.listen((KeyboardEvent key) {
      if (key.keyCode == 13) {
        key.stopPropagation();
        sendMessage(userInput.value);
        userInput.value = '';      
      }
    }); 
  }
  
  showMessage(String message, String author) {
    DivElement msgElement = MessageView.render(message, author);
    
    int userScroll = output.scrollTop + output.borderEdge.height;
    bool scroll = userScroll >= output.scrollHeight;
    
    output.append(msgElement);
    if (scroll) {
      msgElement.scrollIntoView();
    }
  }
  
  showOnline(int count) {
    online.text = 'online: $count';
  }
  
  sendMessage(String message) {
    Map data = {
      'cmd': CMD_SEND_MESSAGE,
      'message': message
    };
    String jdata = JSON.encode(data);
    ws.send(jdata);
  }
}
library simple_dart_chat.client.views;

import "dart:html";

class MessageView {
  
  static DivElement render(String message, String author) {
    DivElement m = new DivElement();
    m.classes.add('message');
    
    DivElement auth = new DivElement();
    auth.classes.add('author');
    auth.text = author;
    
    DivElement text = new DivElement();
    text.classes.add('text');
    text.text = message;
    
    m.append(auth);
    m.append(text);
    
    return m;
  }
  
}
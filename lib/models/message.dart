class ChatMessage {
  ChatMessage({
    required this.msg,
    required this.read,
    required this.told,
    required this.type,
    required this.fromId,
    required this.sent,
  });
  late final String msg;
  late final String read;
  late final String told;
  late final String fromId;
  late final String sent;
  late final Type type;

  static final typeMap = {
    'text': Type.text,
    'image': Type.image,
    'video': Type.video,
    'file': Type.file,
  };

  ChatMessage.fromJson(Map<String, dynamic> json){
    msg = json['msg'].toString();
    read = json['read'].toString();
    told = json['told'].toString();
    type = typeMap[json['type'].toString()] ?? Type.text ;
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['read'] = read;
    data['told'] = told;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    return data;
  }
}

enum Type{text,image,video,file}
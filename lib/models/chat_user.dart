class ChatUser {
  ChatUser({
    required this.name,
    required this.about,
    required this.image,
    required this.createdAt,
    required this.id,
    required this.isOnline,
    required this.lastActive,
    required this.email,
    required this.pushToken,
  });
  late  String name;
  late  String about;
  late  String image;
  late  String createdAt;
  late  String id;
  late  bool isOnline;
  late  String lastActive;
  late  String email;
  late  String pushToken;

  ChatUser.fromJson(Map<String, dynamic> json){
    name = json['name'] ?? "";
    about = json['about'] ?? "";
    image = json['image'] ?? "";
    createdAt = json['created_at'] ?? "";
    id = json['id'] ?? "";
    if (json.containsKey('is_online')) {
    isOnline = json['is_online'];
    } else {
    isOnline = false;
    };
    // isOnline = json['is_online']??"";
    lastActive = json['last_active'] ?? "";
    email = json['email'] ?? "";
    pushToken = json['push_token'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['is_online'] = isOnline;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    return data;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String? userId = "";
  String? userName = "";
  String? userImage = "";

  UserData({this.userId = "", this.userName = "", this.userImage = ""});

  factory UserData.fromJson(Map<String, dynamic>? data) => UserData(
        userId: data?['userId'] as String?,
        userName: data?['userName'] as String?,
        userImage: data?['userImage'] as String?,
      );
  Map<String, dynamic> toMap() => {
    'userId': userId ?? "", // Use null-ish coalescing operator for empty string
    'userName': userName ?? "",
    'userImage': userImage ?? "",
  };
}

class Message {
  String? messageId = "";
  String? messageType = "";
  String? content = "";
  String? senderId = "";
  Timestamp? timestamp = Timestamp.now();

  Message(
      {this.content = "",
        this.messageType = "",
        this.messageId = "",
        this.senderId = "",
        this.timestamp});

  factory Message.fromJson(Map<String, dynamic> data) => Message(
      messageId: data['content'] as String?,
      messageType: data['type'] as String,
      content: data['content'] as String?,
      senderId: data['senderId'] as String?,
      timestamp: data['timestamp'] as Timestamp?);
}

class Chat {
  String? chatId = "";
  UserData? shopper = UserData();
  UserData? admin = UserData();

  Chat({this.chatId = "", this.shopper, this.admin});

  factory Chat.fromJson(Map<String, dynamic> data) => Chat(
        chatId: data['chatId'] as String?,
        shopper: UserData.fromJson(data['shopper'] as Map<String, dynamic>?),
        admin: UserData.fromJson(data['admin'] as Map<String, dynamic>?),
      );
}

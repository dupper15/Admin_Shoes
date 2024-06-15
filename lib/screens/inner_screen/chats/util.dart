import 'dart:io';

import 'package:admin/screens/inner_screen/chats/chat_screen.dart';
import 'package:admin/widgets/subtitle_text.dart';
import 'package:admin/widgets/title_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/my_app_functions.dart';
import 'datatype.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
User? currentUser = auth.currentUser;

void onReplySent(String reply, String type, String chatId, String shopperId) {
  if (reply != '') {
    final messageId =
        db
            .collection("chats")
            .doc(chatId)
            .collection("messages")
            .doc()
            .id;
    Map<String, dynamic> message = {
      "messageId": messageId,
      "type": type,
      "content": reply,
      "senderId": "admin",
      "timestamp": Timestamp.now(),
    };
    db
        .collection("chats")
        .doc("chat_$shopperId")
        .collection("messages")
        .doc(messageId)
        .set(message);
  }
}

class MessageWidget extends StatelessWidget {
  /*
  final String content;
  final String timestamp;*/
  final Message message;

  const MessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    switch (message.messageType) {
      case "text":
        return textMessage(message);
      case "image":
        return imageMessage(message);
    }
    return textMessage(message);
  }
}

String getTimeFromTimeStamp(Timestamp timestamp) {
  return timestamp.toDate().toString().substring(11, 16);
}

// message widget
class ChatWidget extends StatelessWidget {
  final UserData shopper;

  const ChatWidget({super.key, required this.shopper});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: db
            .collection("chats")
            .doc("chat_${shopper.userId}")
            .collection("messages").orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final message = snapshot.data?.docs.first;

        }
        });
  }
}

Widget buildChatList(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: db.collection("chats").snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final chats = snapshot.data?.docs;
        List<Chat> chatList = [];
        for (var chat in chats!) {
          var data = chat.data() as Map<String, dynamic>;
          var tempChat = Chat.fromJson(data);
          chatList.add(tempChat);
        }
        return ListView.builder(
          itemCount: chatList.length,
          itemBuilder: (context, index) {
            final item = chatList[index];
            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(chat: item)));
              },
              child: Row(
                children: [ChatWidget(shopper: item.shopper!)],
              ),
            );
          },
        );
      } else {
        return const Text("Empty");
      }
    },
  );
}

Widget textMessage(Message message) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    margin: const EdgeInsets.only(left: 8.0, top: 4.0, right: 8.0, bottom: 4.0),
    decoration: BoxDecoration(
      color: Colors.blue[100],
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.content!,
          style: const TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 4.0),
        Text(
          getTimeFromTimeStamp(message.timestamp!),
          style: const TextStyle(fontSize: 12.0, color: Colors.grey),
        ),
      ],
    ),
  );
}

Widget imageMessage(Message message) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    margin: const EdgeInsets.only(left: 8.0, top: 4.0, right: 8.0, bottom: 4.0),
    decoration: BoxDecoration(
      color: Colors.blue[100],
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          height: 200,
          child: Image.network(
            message.content!,
            fit: BoxFit.scaleDown,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          getTimeFromTimeStamp(message.timestamp!),
          style: const TextStyle(fontSize: 12.0, color: Colors.grey),
        ),
      ],
    ),
  );
}

Future<String> uploadImage(XFile pickedImage) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child("chatImages")
      .child("chat_${currentUser?.uid}")
      .child("${DateTime
      .now()
      .millisecondsSinceEpoch}.jpg");
  await ref.putFile(File(pickedImage.path));
  return await ref.getDownloadURL();
} //Shopper only

Future<void> onSendImage(BuildContext context, String chatId,
    String shopperId) async {
  XFile? pickedImage;
  final ImagePicker imagePicker = ImagePicker();
  await MyAppFunctions.imagePickerDialog(
    context: context,
    cameraFCT: () async {
      pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        String imageUrl = await uploadImage(pickedImage!);
        onReplySent(imageUrl, "image", chatId, shopperId);
      }
    },
    galleryFCT: () async {
      pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        String imageUrl = await uploadImage(pickedImage!);
        onReplySent(imageUrl, "image", chatId, shopperId);
      }
    },
    removeFCT: () {
      pickedImage = null;
    },
  );
}

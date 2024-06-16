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
        db.collection("chats").doc(chatId).collection("messages").doc().id;
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
            .collection("messages")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final messageContent;
          final messageTimeStamp;
          if (snapshot.data?.docs != null) {
            //do not touch this
            if (snapshot.data!.docs.isNotEmpty) {
              // do not touch this
              if (snapshot.data?.docs.first["type"] == "text") {
                messageContent = "${snapshot.data?.docs.first["content"]} • ";
              } else {
                messageContent = "Hình ảnh • ";
              }
              messageTimeStamp =
                  getTimeFromTimeStamp(snapshot.data?.docs.first["timestamp"]);
            } else {
              messageContent = "";
              messageTimeStamp = "";
            }
          } else {
            messageContent = "";
            messageTimeStamp = "";
          }
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.11,
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const SizedBox(width: 4.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FancyShimmerImage(
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.height * 0.08,
                    imageUrl: shopper.userImage ??
                        'https://i.pinimg.com/originals/8e/18/19/8e1819672696ff794fd2678e7d1ba2fc.jpg',
                  ),
                ),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2.0),
                    TitlesTextWidget(
                      fontSize: 18,
                      label: shopper.userName!,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          messageContent,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          messageTimeStamp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
                /*
          Image(image: shopper.userImage!)*/
              ],
            ),
          );
        });
  }
}

/*return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height *0.11,
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const SizedBox(width: 4.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FancyShimmerImage(
              height: MediaQuery.of(context).size.height *0.08,
              width: MediaQuery.of(context).size.height *0.08,
              imageUrl: shopper.userImage ?? 'https://i.pinimg.com/originals/8e/18/19/8e1819672696ff794fd2678e7d1ba2fc.jpg',

            ),
          ),
          const SizedBox(width: 8.0),
          Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2.0),
              TitlesTextWidget(
                fontSize: 18,
                label: shopper.userName!,
              ),
              Text(
                'ID: ${shopper.userId!}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          /*
          Image(image: shopper.userImage!)*/

        ],
      ),
    );*/

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
  return Card(
    margin: const EdgeInsets.only(left: 8.0, top: 4.0, right: 8.0, bottom: 4.0),

    child: Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
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
    ),
  );
}

Widget imageMessage(Message message) {
  return Card(
    margin: const EdgeInsets.only(left: 8.0, top: 4.0, right: 8.0, bottom: 4.0),
    child: Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: 200,
              height: 200,
              child: Image.network(
                message.content!,
                fit: BoxFit.cover, // or BoxFit.scaleDown based on your needs
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
          ),
          const SizedBox(height: 4.0),
          Text(
            getTimeFromTimeStamp(message.timestamp!),
            style: const TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}


Future<String> uploadImage(XFile pickedImage) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child("chatImages")
      .child("chat_${currentUser?.uid}")
      .child("${DateTime.now().millisecondsSinceEpoch}.jpg");
  await ref.putFile(File(pickedImage.path));
  return await ref.getDownloadURL();
} //Shopper only

Future<void> onSendImage(
    BuildContext context, String chatId, String shopperId) async {
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

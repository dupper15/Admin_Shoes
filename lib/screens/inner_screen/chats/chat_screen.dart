import 'package:admin/screens/inner_screen/chats/util.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/title_text.dart';
import 'chat_screen_reply_bar_widget.dart';
import 'datatype.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = "/ChatScreen";
  final Chat chat;

  const ChatScreen({required this.chat, super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: const TitlesTextWidget(
          label: "Chat",
          fontSize: 22,
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: buildMessageList(context, widget.chat.shopper!.userId!)),
          ChatScreenReplyBar(
            chatId: widget.chat.chatId!,
            shopperId: widget.chat.shopper!.userId!,
          )
        ],
      ),
    );
  }
}

/*child: Builder(
            builder: (context) {
              if (messageList.isEmpty) {
                return const Text("Empty");
              } else {
                return ListView.builder(
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    final item = messageList[index];
                    return ListTile(
                      title: Text(item.content!),
                    );
                  },
                );
              }
            },
          )*/

Widget buildMessageList(BuildContext context, String shopperId) {
  return StreamBuilder<QuerySnapshot>(
    stream: db
        .collection("chats")
        .doc("chat_$shopperId")
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final messages = snapshot.data?.docs;
        List<Message> messageList = [];
        for (var message in messages!) {
          var data = message.data() as Map<String, dynamic>;
          var tempMessage = Message.fromJson(data);
          messageList.add(tempMessage);
        }
        return ListView.builder(
          itemCount: messageList.length,
          itemBuilder: (context, index) {
            final item = messageList[index];
            MainAxisAlignment alignment;
            if (item.senderId.toString() == "admin") {
              alignment = MainAxisAlignment.end;
            } else {
              alignment = MainAxisAlignment.start;
            }
            return Row(
              mainAxisAlignment: alignment,
              children: [MessageWidget(message: item)],
            );
          },
        );
      } else {
        return const Text("Empty");
      }
    },
  );
}

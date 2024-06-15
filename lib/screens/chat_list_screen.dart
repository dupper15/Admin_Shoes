// chat screen widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/title_text.dart';
import 'inner_screen/chats/datatype.dart';
import 'inner_screen/chats/util.dart';

class ChatListScreen extends StatefulWidget {
  static const routName = "/ChatListScreen";
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
        title: const TitlesTextWidget(label: "Chăm sóc khách hàng"),
      ),
      body: Expanded(child: buildChatList(context),
      ),
    );
  }
}

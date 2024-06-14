// chat screen widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        title: const Text('Chats'),
      ),
      body: Expanded(child: buildChatList(context),

      ),
    );
  }
}

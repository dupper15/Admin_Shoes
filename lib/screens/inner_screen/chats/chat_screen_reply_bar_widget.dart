import 'package:admin/screens/inner_screen/chats/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreenReplyBar extends StatefulWidget {
  final String chatId;
  final String shopperId;

  const ChatScreenReplyBar(
      {super.key, required this.chatId, required this.shopperId});

  @override
  _ChatScreenReplyBarState createState() => _ChatScreenReplyBarState();
}

class _ChatScreenReplyBarState extends State<ChatScreenReplyBar> {
  final bool _isLoading = false;
  late final TextEditingController _replyController;

  @override
  void initState() {
    _replyController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _replyController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          IconButton(
          icon: const Icon(Icons.image),
          onPressed: () {
            onSendImage(context, widget.chatId, widget.shopperId);
          },
        ),
          Expanded(
            child: TextFormField(
              controller: _replyController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              String text = _replyController.text.toString();
              onReplySent(text,"text", widget.chatId, widget.shopperId);
              _replyController.clear();
            },
          ),
        ],
      ),
    );
  }
}

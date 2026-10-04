import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../providers/notification_provider.dart';

class ChatScreen extends StatefulWidget {
  final Item item;
  final String otherUserEmail;

  const ChatScreen({
    super.key,
    required this.item,
    required this.otherUserEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    // Get all providers BEFORE any await.
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );

    final notificationProvider =
        Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    final senderEmail = authProvider.email;

    // Clear input immediately.
    _messageController.clear();

    // Send the message ONCE.
    await messageProvider.sendMessage(
      itemId: widget.item.id,
      senderEmail: senderEmail,
      receiverEmail: widget.otherUserEmail,
      text: text,
    );

    // Create notification ONCE.
    await notificationProvider.addNotification(
      receiverEmail: widget.otherUserEmail,
      title: 'New message',
      message:
          '$senderEmail sent you a message about ${widget.item.name}.',
      type: 'message',
    );

    // Make sure the screen is still mounted before using context.
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final messageProvider =
        Provider.of<MessageProvider>(context);

    final messages = messageProvider.getConversation(
      itemId: widget.item.id,
      currentUser: authProvider.email,
      otherUser: widget.otherUserEmail,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
      ),

      body: Column(
        children: [
          // ===================================================
          // ITEM INFORMATION
          // ===================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 40,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(widget.item.location),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===================================================
          // MESSAGES
          // ===================================================

          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'Start a conversation',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      final isMe =
                          message.senderEmail ==
                              authProvider.email;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,

                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ),

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),

                          constraints:
                              const BoxConstraints(
                            maxWidth: 320,
                          ),

                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFF2563EB)
                                : Colors.grey.shade200,

                            borderRadius:
                                BorderRadius.circular(16),
                          ),

                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: isMe
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ===================================================
          // MESSAGE INPUT
          // ===================================================

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),

              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,

                      textInputAction:
                          TextInputAction.send,

                      onSubmitted: (_) {
                        _sendMessage();
                      },

                      decoration: InputDecoration(
                        hintText: 'Type a message...',

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(25),
                        ),

                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CircleAvatar(
                    backgroundColor:
                        const Color(0xFF2563EB),

                    child: IconButton(
                      onPressed: _sendMessage,

                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
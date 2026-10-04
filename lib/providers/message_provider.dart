import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/message.dart';

class MessageProvider extends ChangeNotifier {
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  // ============================================================
  // LOAD MESSAGES
  // ============================================================

  Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();

    final savedMessages =
        prefs.getStringList('messages');

    if (savedMessages == null) {
      _messages = [];
      return;
    }

    _messages = savedMessages.map((message) {
      final data =
          jsonDecode(message) as Map<String, dynamic>;

      return Message(
        id: data['id']?.toString() ?? '',
        itemId: data['itemId']?.toString() ?? '',
        senderEmail:
            data['senderEmail']?.toString() ?? '',
        receiverEmail:
            data['receiverEmail']?.toString() ?? '',
        text: data['text']?.toString() ?? '',
        timestamp:
            DateTime.parse(data['timestamp'].toString()),
      );
    }).toList();

    notifyListeners();
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage({
    required String itemId,
    required String senderEmail,
    required String receiverEmail,
    required String text,
  }) async {
    final message = Message(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      itemId: itemId,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      text: text,
      timestamp: DateTime.now(),
    );

    _messages.add(message);

    await _saveMessages();

    notifyListeners();
  }

  // ============================================================
  // GET CONVERSATION
  // ============================================================

  List<Message> getConversation({
    required String itemId,
    required String currentUser,
    required String otherUser,
  }) {
    final conversation = _messages.where((message) {
      final sameItem =
          message.itemId == itemId;

      final sameConversation =
          (message.senderEmail == currentUser &&
                  message.receiverEmail ==
                      otherUser) ||
              (message.senderEmail == otherUser &&
                  message.receiverEmail ==
                      currentUser);

      return sameItem && sameConversation;
    }).toList();

    conversation.sort(
      (a, b) => a.timestamp.compareTo(b.timestamp),
    );

    return conversation;
  }

  // ============================================================
  // SAVE MESSAGES
  // ============================================================

  Future<void> _saveMessages() async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedMessages =
        _messages.map((message) {
      return jsonEncode({
        'id': message.id,
        'itemId': message.itemId,
        'senderEmail':
            message.senderEmail,
        'receiverEmail':
            message.receiverEmail,
        'text': message.text,
        'timestamp':
            message.timestamp.toIso8601String(),
      });
    }).toList();

    await prefs.setStringList(
      'messages',
      savedMessages,
    );
  }
}
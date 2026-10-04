import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../providers/item_provider.dart';
import '../providers/notification_provider.dart';
import '../models/item.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  int _previousUnreadCount = 0;
  bool _notificationInitialized = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkForNewNotification(int unreadCount) {
    if (!_notificationInitialized) {
      _previousUnreadCount = unreadCount;
      _notificationInitialized = true;
      return;
    }

    if (unreadCount > _previousUnreadCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2563EB),
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New notification',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'You have a new message.',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .hideCurrentSnackBar();

                    Navigator.pushNamed(
                      context,
                      '/notifications',
                    );
                  },
                  child: const Text(
                    'VIEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }

    _previousUnreadCount = unreadCount;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final messageProvider =
        Provider.of<MessageProvider>(context);
    final itemProvider =
        Provider.of<ItemProvider>(context);

    final notificationProvider =
        Provider.of<NotificationProvider>(context);

    final currentUser = authProvider.email;

    final unreadCount =
        notificationProvider.unreadCount(currentUser);

    // Check whether a new notification appeared.
    _checkForNewNotification(unreadCount);

    // ----------------------------------------------------------
    // GET MESSAGES FOR CURRENT USER
    // ----------------------------------------------------------

    final userMessages =
        messageProvider.messages.where((message) {
      return message.senderEmail.toLowerCase() ==
              currentUser.toLowerCase() ||
          message.receiverEmail.toLowerCase() ==
              currentUser.toLowerCase();
    }).toList();

    userMessages.sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    );

    // ----------------------------------------------------------
    // CREATE UNIQUE CONVERSATIONS
    // ----------------------------------------------------------

    final Map<String, dynamic> conversations = {};

    for (final message in userMessages) {
      final otherUser =
          message.senderEmail.toLowerCase() ==
                  currentUser.toLowerCase()
              ? message.receiverEmail
              : message.senderEmail;

      final key = '${message.itemId}_$otherUser';

      if (!conversations.containsKey(key)) {
        conversations[key] = {
          'message': message,
          'otherUser': otherUser,
        };
      }
    }

    final conversationList =
        conversations.values.where((conversation) {
      final message = conversation['message'];
      final otherUser =
          conversation['otherUser'].toString();

      final item = _findItem(
        itemProvider.items,
        message.itemId.toString(),
      );

      final itemName = item?.name ?? '';

      if (_searchText.isEmpty) {
        return true;
      }

      final search =
          _searchText.toLowerCase();

      final userName =
          authProvider.getUserNameByEmail(otherUser);

      return userName
              .toLowerCase()
              .contains(search) ||
          otherUser
              .toLowerCase()
              .contains(search) ||
          itemName
              .toLowerCase()
              .contains(search) ||
          message.text
              .toString()
              .toLowerCase()
              .contains(search);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7FF),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        centerTitle: true,

        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 27,
            fontWeight: FontWeight.w500,
          ),
        ),

        actions: [
          // ====================================================
          // NOTIFICATION BELL
          // ====================================================

          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Notifications',
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black,
                    size: 29,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/notifications',
                    );
                  },
                ),

                if (unreadCount > 0)
                  Positioned(
                    right: 2,
                    top: 3,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 19,
                        minHeight: 19,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF9F7FF),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99
                              ? '99+'
                              : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Column(
        children: [
          // ----------------------------------------------------
          // SEARCH
          // ----------------------------------------------------

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon:
                    const Icon(Icons.search),

                suffixIcon:
                    _searchText.isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();

                              setState(() {
                                _searchText = '';
                              });
                            },
                          )
                        : null,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // ----------------------------------------------------
          // NOTIFICATION BANNER
          // ----------------------------------------------------

          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                12,
              ),
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(14),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/notifications',
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEFF),
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFB9C8FF),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF2563EB),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              unreadCount == 1
                                  ? '1 new notification'
                                  : '$unreadCount new notifications',
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Tap to view',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ----------------------------------------------------
          // CONVERSATIONS
          // ----------------------------------------------------

          Expanded(
            child: conversationList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    itemCount:
                        conversationList.length,
                    itemBuilder:
                        (context, index) {
                      final conversation =
                          conversationList[index];

                      final message =
                          conversation['message'];

                      final otherUser =
                          conversation['otherUser']
                              .toString();

                      final item = _findItem(
                        itemProvider.items,
                        message.itemId.toString(),
                      );

                      final userName =
                          authProvider
                              .getUserNameByEmail(
                        otherUser,
                      );

                      return _ConversationCard(
                        userName: userName,
                        otherUser: otherUser,
                        lastMessage:
                            message.text.toString(),
                        itemName:
                            item?.name ?? 'Item',
                        timestamp:
                            message.timestamp,
                        onTap: item == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChatScreen(
                                      item: item,
                                      otherUserEmail:
                                          otherUser,
                                    ),
                                  ),
                                );
                              },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FIND ITEM
  // ==========================================================

  Item? _findItem(
    List<Item> items,
    String itemId,
  ) {
    for (final item in items) {
      if (item.id == itemId) {
        return item;
      }
    }

    return null;
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.5),
            ),

            const SizedBox(height: 20),

            const Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Contact an item owner to start a conversation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CONVERSATION CARD
// ============================================================

class _ConversationCard extends StatelessWidget {
  final String userName;
  final String otherUser;
  final String lastMessage;
  final String itemName;
  final DateTime timestamp;
  final VoidCallback? onTap;

  const _ConversationCard({
    required this.userName,
    required this.otherUser,
    required this.lastMessage,
    required this.itemName,
    required this.timestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';

    final initial = userName.isNotEmpty
        ? userName[0].toUpperCase()
        : '?';

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 4,
      ),
      elevation: 1,
      child: ListTile(
        onTap: onTap,

        // ------------------------------------------------------
        // USER AVATAR
        // ------------------------------------------------------

        leading: CircleAvatar(
          radius: 25,
          child: Text(
            initial,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // ------------------------------------------------------
        // USER NAME + EMAIL
        // ------------------------------------------------------

        title: Text(
          userName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),

            Text(
              otherUser,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              itemName,
              style: TextStyle(
                color:
                    Theme.of(context)
                        .colorScheme
                        .primary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              lastMessage,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ],
        ),

        // ------------------------------------------------------
        // TIME
        // ------------------------------------------------------

        trailing: Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
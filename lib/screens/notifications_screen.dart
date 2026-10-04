import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _getIcon(String type) {
    switch (type) {
      case 'message':
        return Icons.chat_bubble_outline;

      case 'item':
        return Icons.inventory_2_outlined;

      case 'match':
        return Icons.search;

      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'message':
        return const Color(0xFF2563EB);

      case 'item':
        return const Color(0xFF16A34A);

      case 'match':
        return const Color(0xFFF59E0B);

      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notificationProvider =
        Provider.of<NotificationProvider>(context);

    final notifications =
        notificationProvider.getUserNotifications(
      authProvider.email,
    );

    final unreadCount =
        notificationProvider.unreadCount(
      authProvider.email,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,

        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                notificationProvider.markAllAsRead(
                  authProvider.email,
                );
              },
              child: const Text('Read all'),
            ),
        ],
      ),

      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification =
                    notifications[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  elevation:
                      notification.isRead ? 0 : 2,
                  color: notification.isRead
                      ? Colors.white
                      : const Color(0xFFEFF6FF),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),

                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.all(14),

                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          _getIconColor(notification.type)
                              .withValues(alpha: 0.12),
                      child: Icon(
                        _getIcon(notification.type),
                        color:
                            _getIconColor(notification.type),
                      ),
                    ),

                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                            ),
                          ),
                        ),

                        if (!notification.isRead)
                          Container(
                            width: 9,
                            height: 9,
                            decoration:
                                const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    subtitle: Padding(
                      padding:
                          const EdgeInsets.only(top: 5),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.message,
                          ),

                          const SizedBox(height: 5),

                          Text(
                            _formatTime(
                              notification.timestamp,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    onTap: () {
                      notificationProvider.markAsRead(
                        notification.id,
                      );
                    },

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          notificationProvider
                              .deleteNotification(
                            notification.id,
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.5),
            ),

            const SizedBox(height: 20),

            const Text(
              'No notifications',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'You will see messages and important updates here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  // =========================================================
  // LOAD NOTIFICATIONS
  // =========================================================

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    final savedNotifications =
        prefs.getStringList('notifications');

    if (savedNotifications == null) {
      _notifications = [];
      return;
    }

    _notifications = savedNotifications.map((notification) {
      final data =
          jsonDecode(notification) as Map<String, dynamic>;

      return AppNotification(
        id: data['id']?.toString() ?? '',
        receiverEmail:
            data['receiverEmail']?.toString() ?? '',
        title: data['title']?.toString() ?? '',
        message: data['message']?.toString() ?? '',
        type: data['type']?.toString() ?? '',
        timestamp:
            DateTime.parse(data['timestamp'].toString()),
        isRead: data['isRead'] ?? false,
      );
    }).toList();

    notifyListeners();
  }

  // =========================================================
  // GET NOTIFICATIONS FOR CURRENT USER
  // =========================================================

  List<AppNotification> getUserNotifications(
    String email,
  ) {
    return _notifications
        .where(
          (notification) =>
              notification.receiverEmail.toLowerCase() ==
              email.toLowerCase(),
        )
        .toList()
      ..sort(
        (a, b) => b.timestamp.compareTo(a.timestamp),
      );
  }

  // =========================================================
  // UNREAD COUNT
  // =========================================================

  int unreadCount(String email) {
    return _notifications.where((notification) {
      return notification.receiverEmail.toLowerCase() ==
              email.toLowerCase() &&
          !notification.isRead;
    }).length;
  }

  // =========================================================
  // ADD NOTIFICATION
  // =========================================================

  Future<void> addNotification({
    required String receiverEmail,
    required String title,
    required String message,
    required String type,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      receiverEmail: receiverEmail,
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, notification);

    await _saveNotifications();

    notifyListeners();
  }

  // =========================================================
  // MARK ONE AS READ
  // =========================================================

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );

    if (index == -1) {
      return;
    }

    _notifications[index] =
        _notifications[index].copyWith(isRead: true);

    await _saveNotifications();

    notifyListeners();
  }

  // =========================================================
  // MARK ALL AS READ
  // =========================================================

  Future<void> markAllAsRead(String email) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].receiverEmail.toLowerCase() ==
          email.toLowerCase()) {
        _notifications[i] =
            _notifications[i].copyWith(isRead: true);
      }
    }

    await _saveNotifications();

    notifyListeners();
  }

  // =========================================================
  // DELETE NOTIFICATION
  // =========================================================

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere(
      (notification) => notification.id == id,
    );

    await _saveNotifications();

    notifyListeners();
  }

  // =========================================================
  // SAVE
  // =========================================================

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    final savedNotifications =
        _notifications.map((notification) {
      return jsonEncode({
        'id': notification.id,
        'receiverEmail': notification.receiverEmail,
        'title': notification.title,
        'message': notification.message,
        'type': notification.type,
        'timestamp':
            notification.timestamp.toIso8601String(),
        'isRead': notification.isRead,
      });
    }).toList();

    await prefs.setStringList(
      'notifications',
      savedNotifications,
    );
  }
}
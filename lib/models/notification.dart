class AppNotification {
  final String id;
  final String receiverEmail;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.receiverEmail,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      receiverEmail: receiverEmail,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
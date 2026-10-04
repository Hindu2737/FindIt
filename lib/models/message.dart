class Message {
  final String id;
  final String itemId;
  final String senderEmail;
  final String receiverEmail;
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.itemId,
    required this.senderEmail,
    required this.receiverEmail,
    required this.text,
    required this.timestamp,
  });
}
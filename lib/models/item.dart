class Item {
  final String id;
  final String name;
  final String category;
  final String location;
  final DateTime date;
  final String color;
  final String brand;
  final String description;
  final bool isLost;
  final String ownerEmail;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.date,
    required this.color,
    required this.brand,
    required this.description,
    required this.isLost,
    required this.ownerEmail,
  });
}
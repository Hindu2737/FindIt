import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/auth_provider.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Item item;

  const ItemDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final bool isMyItem =
        item.ownerEmail == authProvider.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 800,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: item.isLost
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.isLost ? 'LOST ITEM' : 'FOUND ITEM',
                    style: TextStyle(
                      color: item.isLost
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Item name
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _detailRow(
                          Icons.category_outlined,
                          'Category',
                          item.category,
                        ),
                        _detailRow(
                          Icons.location_on_outlined,
                          'Location',
                          item.location,
                        ),
                        _detailRow(
                          Icons.calendar_today_outlined,
                          'Date',
                          '${item.date.day}/${item.date.month}/${item.date.year}',
                        ),
                        _detailRow(
                          Icons.palette_outlined,
                          'Color',
                          item.color,
                        ),
                        _detailRow(
                          Icons.sell_outlined,
                          'Brand',
                          item.brand,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                if (!isMyItem)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: {
                            'item': item,
                            'otherUserEmail':
                                item.ownerEmail,
                          },
                        );
                      },
                      icon: const Icon(Icons.chat_outlined),
                      label: const Text(
                        'Contact Owner',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'This is your item.',
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 15),
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
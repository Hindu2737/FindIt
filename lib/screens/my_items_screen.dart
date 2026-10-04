import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  bool showLost = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);

    final myItems = itemProvider.items.where((item) {
      return item.ownerEmail == authProvider.email &&
          item.isLost == showLost;
    }).toList();

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Items'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Lost / Found selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Lost Items'),
                    selected: showLost,
                    onSelected: (value) {
                      if (value) {
                        setState(() {
                          showLost = true;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Found Items'),
                    selected: !showLost,
                    onSelected: (value) {
                      if (value) {
                        setState(() {
                          showLost = false;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: myItems.isEmpty
                ? _buildEmptyState()
                : width >= 700
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: myItems.length,
                        itemBuilder: (context, index) {
                          return _ItemCard(
                            item: myItems[index],
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: myItems.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ItemCard(
                              item: myItems[index],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 70,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            showLost
                ? 'You have not reported any lost items.'
                : 'You have not reported any found items.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;

  const _ItemCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final itemProvider =
        Provider.of<ItemProvider>(context, listen: false);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    item.isLost
                        ? Icons.search
                        : Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _confirmDelete(
                      context,
                      itemProvider,
                      item,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text('Category: ${item.category}'),
            const SizedBox(height: 5),
            Text('Location: ${item.location}'),
            const SizedBox(height: 5),
            Text('Color: ${item.color}'),
            const SizedBox(height: 5),
            Text('Brand: ${item.brand}'),
            const SizedBox(height: 5),
            Text(
              'Date: ${item.date.day}/${item.date.month}/${item.date.year}',
            ),

            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ItemProvider itemProvider,
    Item item,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Item?'),
          content: Text(
            'Are you sure you want to delete "${item.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await itemProvider.deleteItem(item.id);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item deleted successfully'),
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
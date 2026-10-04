import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/item_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedCategory = 'All';
  String selectedType = 'All';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Item> _getFilteredItems(List<Item> items) {
    final query = searchController.text.toLowerCase().trim();

    return items.where((item) {
      final matchesSearch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query) ||
          item.brand.toLowerCase().contains(query) ||
          item.color.toLowerCase().contains(query);

      final matchesCategory =
          selectedCategory == 'All' ||
          item.category == selectedCategory;

      final itemType = item.isLost ? 'Lost' : 'Found';

      final matchesType =
          selectedType == 'All' ||
          itemType == selectedType;

      return matchesSearch &&
          matchesCategory &&
          matchesType;
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final itemProvider = Provider.of<ItemProvider>(context);

    final filteredItems =
        _getFilteredItems(itemProvider.items);

    final bool isDesktop = screenWidth >= 900;
    final bool isTablet = screenWidth >= 600;

    double horizontalPadding;

    if (isDesktop) {
      horizontalPadding = 80;
    } else if (isTablet) {
      horizontalPadding = 40;
    } else {
      horizontalPadding = 16;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool desktop =
              constraints.maxWidth >= 900;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // Heading
                Text(
                  'Find an Item',
                  style: TextStyle(
                    fontSize: desktop
                        ? 32
                        : isTablet
                            ? 28
                            : 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Search for lost and found items on campus.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 20),

                // Search field
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Search by item, category, location or brand',
                    prefixIcon:
                        const Icon(Icons.search),
                    suffixIcon:
                        searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  searchController.clear();

                                  setState(() {});
                                },
                                icon:
                                    const Icon(Icons.clear),
                              )
                            : const Icon(Icons.tune),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Filters
                if (desktop)
                  Row(
                    children: [
                      Expanded(
                        child:
                            _buildCategoryFilter(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child:
                            _buildTypeFilter(),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildCategoryFilter(),
                      const SizedBox(height: 12),
                      _buildTypeFilter(),
                    ],
                  ),

                const SizedBox(height: 28),

                // Results heading
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredItems.length} Items Found',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (selectedCategory != 'All' ||
                        selectedType != 'All')
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = 'All';
                            selectedType = 'All';
                          });
                        },
                        child:
                            const Text('Clear Filters'),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Results
                if (filteredItems.isEmpty)
                  _buildEmptyState()
                else if (desktop)
                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item =
                          filteredItems[index];

                      return _ItemCard(
                        item: item,
                        date:
                            _formatDate(item.date),
                      );
                    },
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item =
                          filteredItems[index];

                      return _ItemCard(
                        item: item,
                        date:
                            _formatDate(item.date),
                      );
                    },
                  ),

                const SizedBox(height: 25),

                Center(
                  child: Text(
                    'Screen width: ${screenWidth.toStringAsFixed(0)} px',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return _FilterSection(
      title: 'Category',
      child: DropdownButtonFormField<String>(
        initialValue: selectedCategory,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        items: const [
          DropdownMenuItem(
            value: 'All',
            child: Text('All Categories'),
          ),
          DropdownMenuItem(
            value: 'Electronics',
            child: Text('Electronics'),
          ),
          DropdownMenuItem(
            value: 'Books',
            child: Text('Books'),
          ),
          DropdownMenuItem(
            value: 'Documents',
            child: Text('Documents'),
          ),
          DropdownMenuItem(
            value: 'Accessories',
            child: Text('Accessories'),
          ),
          DropdownMenuItem(
            value: 'Clothing',
            child: Text('Clothing'),
          ),
          DropdownMenuItem(
            value: 'Keys',
            child: Text('Keys'),
          ),
          DropdownMenuItem(
            value: 'Bags',
            child: Text('Bags'),
          ),
          DropdownMenuItem(
            value: 'Other',
            child: Text('Other'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedCategory = value!;
          });
        },
      ),
    );
  }

  Widget _buildTypeFilter() {
    return _FilterSection(
      title: 'Item Type',
      child: DropdownButtonFormField<String>(
        initialValue: selectedType,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        items: const [
          DropdownMenuItem(
            value: 'All',
            child: Text('Lost + Found'),
          ),
          DropdownMenuItem(
            value: 'Lost',
            child: Text('Lost Items'),
          ),
          DropdownMenuItem(
            value: 'Found',
            child: Text('Found Items'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedType = value!;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey,
          ),

          SizedBox(height: 15),

          Text(
            'No items found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Try changing your search or filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        child,
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final String date;

  const _ItemCard({
    required this.item,
    required this.date,
  });

  IconData get icon {
    switch (item.category) {
      case 'Electronics':
        return Icons.devices_outlined;
      case 'Bags':
        return Icons.backpack_outlined;
      case 'Keys':
        return Icons.key;
      case 'Books':
        return Icons.book_outlined;
      case 'Documents':
        return Icons.description_outlined;
      case 'Accessories':
        return Icons.watch_outlined;
      case 'Clothing':
        return Icons.checkroom_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFound = !item.isLost;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/item-details',
            arguments: item,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              // Item icon
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: const Color(0xFF2563EB),
                ),
              ),

              const SizedBox(width: 15),

              // Item information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 3),

                        Expanded(
                          child: Text(
                            item.location,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          date,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${item.color} • ${item.brand}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Lost / Found badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isFound
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isFound ? 'Found' : 'Lost',
                  style: TextStyle(
                    color: isFound
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFF59E0B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 5),

              // Arrow showing that the card is clickable
              const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'FindIt',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Greeting
              const Text(
                'Hi, Student 👋',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Let\'s find what you lost.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search lost or found items',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.tune),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Main actions
              Row(
                children: [

                  Expanded(
                    child: _ActionCard(
                      title: 'I Lost\nSomething',
                      icon: Icons.search,
                      color: const Color(0xFF2563EB),
                      onTap: () {
                        Navigator.pushNamed(context, '/report-lost');
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _ActionCard(
                      title: 'I Found\nSomething',
                      icon: Icons.inventory_2_outlined,
                      color: const Color(0xFF16A34A),
                      onTap: () {
                        Navigator.pushNamed(context, '/report-found');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Categories
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 95,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _CategoryItem(
                      icon: Icons.phone_android,
                      title: 'Phones',
                    ),
                    _CategoryItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Wallets',
                    ),
                    _CategoryItem(
                      icon: Icons.key,
                      title: 'Keys',
                    ),
                    _CategoryItem(
                      icon: Icons.backpack_outlined,
                      title: 'Bags',
                    ),
                    _CategoryItem(
                      icon: Icons.book_outlined,
                      title: 'Books',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Recently found
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recently Found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/search');
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const _ItemCard(
                icon: Icons.phone_android,
                itemName: 'Black Smartphone',
                location: 'Library - 2nd Floor',
                time: '2 hours ago',
                status: 'Found',
              ),

              const _ItemCard(
                icon: Icons.backpack_outlined,
                itemName: 'Blue Backpack',
                location: 'Block B',
                time: 'Yesterday',
                status: 'Found',
              ),

              const _ItemCard(
                icon: Icons.water_drop_outlined,
                itemName: 'Blue Water Bottle',
                location: 'Canteen',
                time: 'Yesterday',
                status: 'Found',
              ),
            ],
          ),
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/search');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/report-lost');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/messages');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/profile');
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}


// ============================================================
// CUSTOM ACTION CARD
// ============================================================

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),

      child: Container(
        height: 125,
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// CATEGORY ITEM
// ============================================================

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CategoryItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      margin: const EdgeInsets.only(right: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: const Color(0xFF2563EB),
            size: 30,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// ITEM CARD
// ============================================================

class _ItemCard extends StatelessWidget {
  final IconData icon;
  final String itemName;
  final String location;
  final String time;
  final String status;

  const _ItemCard({
    required this.icon,
    required this.itemName,
    required this.location,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

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
                    itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Text(
                status,
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
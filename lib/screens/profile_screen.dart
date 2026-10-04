import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final String name =
        authProvider.name.isEmpty ? 'User' : authProvider.name;

    final String studentId =
        authProvider.studentId.isEmpty
            ? 'Not available'
            : authProvider.studentId;

    final String email =
        authProvider.email.isEmpty
            ? 'Not available'
            : authProvider.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile icon
            const CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xFF2563EB),
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // Name
            Text(
              name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // Email
            Text(
              email,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            // Account information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline,
                      title: 'Full Name',
                      value: name,
                    ),

                    const Divider(),

                    _InfoRow(
                      icon: Icons.badge_outlined,
                      title: 'Student ID',
                      value: studentId,
                    ),

                    const Divider(),

                    _InfoRow(
                      icon: Icons.email_outlined,
                      title: 'College Email',
                      value: email,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // My Items button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/my-items',
                  );
                },
                icon: const Icon(
                  Icons.inventory_2_outlined,
                ),
                label: const Text(
                  'My Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.logout();

                  if (!context.mounted) return;

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF2563EB),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
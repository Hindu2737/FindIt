import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/item.dart';

import 'providers/auth_provider.dart';
import 'providers/item_provider.dart';
import 'providers/message_provider.dart';
import 'providers/notification_provider.dart';

import 'screens/notifications_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/signin_page.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/report_item_screen.dart';
import 'screens/my_items_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/item_details_screen.dart';
import 'screens/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved authentication data
  final authProvider = AuthProvider();
  await authProvider.loadAccount();

  // Load saved lost/found items
  final itemProvider = ItemProvider();
  await itemProvider.loadItems();

  // Load saved messages
  final messageProvider = MessageProvider();
  await messageProvider.loadMessages();
  
  final notificationProvider =
    NotificationProvider();
  await notificationProvider.loadNotifications();
  // IMPORTANT: Actually start the Flutter application
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: authProvider,
        ),

        ChangeNotifierProvider.value(
          value: itemProvider,
        ),

        ChangeNotifierProvider.value(
          value: messageProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: const FindItApp(),
    ),
  );
}

class FindItApp extends StatelessWidget {
  const FindItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'FindIt',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        useMaterial3: true,
      ),

      initialRoute: '/',

      routes: {
        // Splash
        '/': (context) => const SplashScreen(),

        // Authentication
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),

        // Main pages
        '/home': (context) => const HomeScreen(),
        '/search': (context) => const SearchScreen(),

        // Report items
        '/report-lost': (context) => const ReportItemScreen(
              isLost: true,
            ),

        '/report-found': (context) => const ReportItemScreen(
              isLost: false,
            ),

        // Messages
        '/messages': (context) => const MessagesScreen(),

        // Profile
        '/profile': (context) => const ProfileScreen(),

        '/my-items': (context) => const MyItemsScreen(),
        '/item-details': (context) {
          final item =
              ModalRoute.of(context)!.settings.arguments as Item;
          
          return ItemDetailsScreen(
            item: item,
          );
        },
        '/chat': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ChatScreen(
            item: args['item'] as Item,
            otherUserEmail: args['otherUserEmail'] as String,
          );
        },

        // Notifications
        '/notifications': (context) =>
            const NotificationsScreen(),
      },
    );
  }
}

// Temporary placeholder screen
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: const Color(0xFF2563EB),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'This screen will be implemented next.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_theme.dart';
import 'screens/root_navigation_screen.dart';

/// Entrypoint of the FoodRescue baseline sandbox application.
/// Presentation defense context:
/// - To activate Riverpod reactive state management globally, we wrap [MyApp] inside
///   a [ProviderScope]. This holds the state storage of all our mock repository and CRUD providers.
/// - We load our premium custom [AppTheme.darkTheme] to override default Material styles.
/// - The root visual widget is [RootNavigationScreen], which manages our rigid bottom navigation tab views.
void main() {
  runApp(
    // ProviderScope is the container for all Riverpod providers.
    // Crucial for dependency injection and state preservation.
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodRescue Sandbox',
      
      // Load custom design token theme (dark mode slate/emerald palette)
      theme: AppTheme.darkTheme,
      
      // Mount the main shell navigation containing bottom tabs
      home: const RootNavigationScreen(),
      
      // Clean UI by disabling default debug banner
      debugShowCheckedModeBanner: false,
    );
  }
}

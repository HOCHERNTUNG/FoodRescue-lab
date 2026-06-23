import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'screens/root_navigation_screen.dart';

/// Entrypoint of the FoodRescue baseline sandbox application.
/// Presentation defense context:
/// - We initialize Firebase before rendering any widgets so authentication
///   and user state are available immediately.
/// - [ProviderScope] contains all Riverpod providers, including auth state.
/// - [AuthGatekeeper] decides whether to display [LoginScreen] or
///   [RootNavigationScreen] based on the current signed-in user.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
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
      theme: AppTheme.darkTheme,
      home: const AuthGatekeeper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGatekeeper extends ConsumerWidget {
  const AuthGatekeeper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        if (!user.emailVerified) {
          return const VerificationWaitingScreen();
        }

        return const RootNavigationScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Authentication error: $error'),
        ),
      ),
    );
  }
}

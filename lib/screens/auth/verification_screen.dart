import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../root_navigation_screen.dart';

class VerificationWaitingScreen extends ConsumerWidget {
  const VerificationWaitingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onSurface.withOpacity(0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Icon(
                        Icons.email_outlined,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Email Verification Required',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Epilogue',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'A verification link has been sent to your email address. Please check your inbox and verify your account to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 15,
                        height: 1.6,
                        color: colorScheme.onSurface.withOpacity(0.78),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        await _handleVerificationCheck(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('I Have Verified My Email'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        await _handleResendVerification(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        textStyle: const TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Resend Verification Email'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        await _handleCancel(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        textStyle: const TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleVerificationCheck(BuildContext context) async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final isVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (isVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RootNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account not verified yet. Please check your email link.'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleResendVerification(BuildContext context) async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email resent successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleCancel(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // Ignore sign-out failures and allow navigation back to login.
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

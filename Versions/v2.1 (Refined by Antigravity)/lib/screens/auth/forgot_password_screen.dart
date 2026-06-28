import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

final _forgotPasswordFormKey = GlobalKey<FormState>();

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = ref.watch(_forgotPasswordEmailControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryTextColor = _onSurfaceVariantColor(context);
    final borderColor = _outlineVariantColor(context);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Reset your password',
                      style: TextStyle(
                        fontFamily: 'Epilogue',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter your email address and we will send reset instructions.',
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Form(
                      key: _forgotPasswordFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionLabel('Email Address', secondaryTextColor),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: _buildInputDecoration(
                              context,
                              hintText: 'name@example.com',
                              icon: Icons.mail_outline,
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Please enter your email address.';
                              }
                              const emailPattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
                              if (!RegExp(emailPattern).hasMatch(text)) {
                                return 'Enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 26),
                          ElevatedButton(
                            onPressed: () async {
                              if (_forgotPasswordFormKey.currentState?.validate() ?? false) {
                                await _handlePasswordReset(context, ref, emailController);
                              }
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
                            child: const Text('Send reset email'),
                          ),
                        ],
                      ),
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

  Future<void> _handlePasswordReset(
    BuildContext context,
    WidgetRef ref,
    TextEditingController emailController,
  ) async {
    try {
      await ref.read(firebaseServiceProvider).sendPasswordResetEmail(emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent successfully!'),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      final message = error is Exception ? error.toString() : 'An unexpected error occurred.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Color _outlineVariantColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dynamic maybe = colorScheme;
    try {
      final outlineVariant = maybe.outlineVariant;
      if (outlineVariant is Color) {
        return outlineVariant;
      }
    } catch (_) {}
    return colorScheme.onSurface.withAlpha(31);
  }

  Color _onSurfaceVariantColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dynamic maybe = colorScheme;
    try {
      final onSurfaceVariant = maybe.onSurfaceVariant;
      if (onSurfaceVariant is Color) {
        return onSurfaceVariant;
      }
    } catch (_) {}
    return colorScheme.onSurface.withAlpha(153);
  }

  Widget _buildSectionLabel(String text, Color color) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.05,
        color: color,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String hintText,
    required IconData icon,
  }) {
    final borderColor = _outlineVariantColor(context);
    return InputDecoration(
      prefixIcon: Icon(icon, color: borderColor),
      hintText: hintText,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
    );
  }
}

final _forgotPasswordEmailControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

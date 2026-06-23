import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

final _signupFormKey = GlobalKey<FormState>();

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = ref.watch(_signupNameControllerProvider);
    final emailController = ref.watch(_signupEmailControllerProvider);
    final passwordController = ref.watch(_signupPasswordControllerProvider);
    final confirmPasswordController = ref.watch(_signupConfirmPasswordControllerProvider);
    final obscurePassword = ref.watch(_signupObscurePasswordProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = _outlineVariantColor(context);
    final secondaryTextColor = _onSurfaceVariantColor(context);

    return Scaffold(
      backgroundColor: colorScheme.background,
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
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onSurface.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create account',
                      style: TextStyle(
                        fontFamily: 'Epilogue',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Start rescuing food with your new account.',
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Form(
                      key: _signupFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionLabel('Name', secondaryTextColor),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: nameController,
                            decoration: _buildInputDecoration(
                              context,
                              hintText: 'Your full name',
                              icon: Icons.person_outline,
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Please enter your name.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 20),
                          _buildSectionLabel('Password', secondaryTextColor),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: _buildInputDecoration(
                              context,
                              hintText: 'Enter a password',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: borderColor,
                                ),
                                onPressed: () {
                                  ref.read(_signupObscurePasswordProvider.notifier).state = !obscurePassword;
                                },
                              ),
                            ),
                            validator: (value) {
                              final text = value ?? '';
                              if (text.isEmpty) {
                                return 'Please enter a password.';
                              }
                              if (text.length < 8) {
                                return 'Password must be at least 8 characters.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildSectionLabel('Confirm Password', secondaryTextColor),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: obscurePassword,
                            decoration: _buildInputDecoration(
                              context,
                              hintText: 'Repeat your password',
                              icon: Icons.lock_outline,
                            ),
                            validator: (value) {
                              final text = value ?? '';
                              if (text.isEmpty) {
                                return 'Please confirm your password.';
                              }
                              if (text != passwordController.text) {
                                return 'Passwords do not match.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 26),
                          ElevatedButton(
                            onPressed: () async {
                              if (_signupFormKey.currentState?.validate() ?? false) {
                                await _handleSignup(context, ref, emailController, passwordController);
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
                            child: const Text('Create account'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
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

  Future<void> _handleSignup(
    BuildContext context,
    WidgetRef ref,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) async {
    try {
      await ref.read(firebaseServiceProvider).signUp(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      _showErrorSnackbar(context, error);
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
    return colorScheme.onSurface.withOpacity(0.12);
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
    return colorScheme.onSurface.withOpacity(0.6);
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
    Widget? suffixIcon,
  }) {
    final borderColor = _outlineVariantColor(context);
    return InputDecoration(
      prefixIcon: Icon(icon, color: borderColor),
      suffixIcon: suffixIcon,
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

  void _showErrorSnackbar(BuildContext context, Object error) {
    final message = error is Exception ? error.toString() : 'An unexpected error occurred.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

final _signupNameControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

final _signupEmailControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

final _signupPasswordControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

final _signupConfirmPasswordControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

final _signupObscurePasswordProvider = StateProvider.autoDispose<bool>((ref) => true);

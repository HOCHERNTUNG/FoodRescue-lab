import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

final _loginFormKey = GlobalKey<FormState>();

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = ref.watch(_loginEmailControllerProvider);
    final passwordController = ref.watch(_loginPasswordControllerProvider);
    final obscurePassword = ref.watch(_loginObscurePasswordProvider);
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
                      color: colorScheme.onSurface.withAlpha(20),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(colorScheme, secondaryTextColor),
                    const SizedBox(height: 28),
                    Form(
                      key: _loginFormKey,
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
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionLabel('Password', secondaryTextColor),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  textStyle: const TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: const Text('Forgot Password?'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            autofillHints: const [AutofillHints.password],
                            decoration: _buildInputDecoration(
                              context,
                              hintText: '••••••••',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: borderColor,
                                ),
                                onPressed: () {
                                  ref.read(_loginObscurePasswordProvider.notifier).state = !obscurePassword;
                                },
                              ),
                            ),
                            validator: (value) {
                              final text = value ?? '';
                              if (text.isEmpty) {
                                return 'Please enter your password.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 26),
                          ElevatedButton(
                            onPressed: () async {
                              if (_loginFormKey.currentState?.validate() ?? false) {
                                await _handleLogin(context, ref, emailController, passwordController);
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
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildOrDivider(context),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await _handleGoogleSignIn(context, ref);
                      },
                      icon: Icon(Icons.g_mobiledata, color: colorScheme.onSurface),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        backgroundColor: colorScheme.surface,
                        side: BorderSide(color: borderColor, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'New to FoodRescue? ',
                            style: TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                            children: [
                              TextSpan(
                                text: 'Create Account',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
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

  Future<void> _handleLogin(
    BuildContext context,
    WidgetRef ref,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) async {
    try {
      await ref.read(firebaseServiceProvider).logIn(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login successful!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (error) {
      _showErrorSnackbar(context, error);
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(firebaseServiceProvider).signInWithGoogle();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Google login successful!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
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
    } catch (_) {
      // Fallback when outlineVariant is not available.
    }
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
    } catch (_) {
      // Fallback when onSurfaceVariant is not available.
    }
    return colorScheme.onSurface.withAlpha(153);
  }

  Widget _buildHeader(ColorScheme colorScheme, Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 68,
          width: 68,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.restaurant,
            size: 32,
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'FoodRescue',
          style: TextStyle(
            fontFamily: 'Epilogue',
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Welcome back. Let's make an impact.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
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

  Widget _buildOrDivider(BuildContext context) {
    final dividerColor = _outlineVariantColor(context).withAlpha(128);

    return Row(
      children: [
        Expanded(
          child: Divider(color: dividerColor, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _onSurfaceVariantColor(context),
            ),
          ),
        ),
        Expanded(
          child: Divider(color: dividerColor, thickness: 1),
        ),
      ],
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
    final String message;
    if (error is Exception) {
      message = error.toString();
    } else {
      message = 'An unexpected error occurred.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

final _loginEmailControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

final _loginPasswordControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

final _loginObscurePasswordProvider = StateProvider.autoDispose<bool>((ref) => true);

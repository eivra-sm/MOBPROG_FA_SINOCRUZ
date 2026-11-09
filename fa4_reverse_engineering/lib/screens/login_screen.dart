import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'register_screen.dart';
import 'home_screen.dart';
import 'package:fa4_reverse_engineering/commons/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const LoginScreen({super.key, this.onToggleTheme});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    final rawUsername = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      final db = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://flutter-reverse-engineering-default-rtdb.asia-southeast1.firebasedatabase.app',
      );

      final snapshot = await db.ref('users/$rawUsername').get();

      if (!snapshot.exists) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showErrorDialog(
          title: 'Login failed.',
          message: 'Invalid username or password',
        );
        return;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final storedPassword = data['password']?.toString() ?? '';

      if (storedPassword != password) {
        if (!mounted) return;

        setState(() => _isLoading = false);

        _showErrorDialog(
          title: 'Login failed.',
          message: 'Invalid username or password',
        );
        return;
      }

      if (!mounted) return;

      setState(() => _isLoading = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            username: rawUsername,
            onToggleTheme: widget.onToggleTheme,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      _showErrorDialog(
        title: 'Login failed.',
        message: 'Invalid username or password',
      );
    }
  }

  void _showErrorDialog({required String title, required String message}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.brown : AppColors.peach,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? AppColors.peach : AppColors.brown,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? AppColors.peach : AppColors.brown,
            fontSize: 15,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 20, bottom: 16),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isDark
                  ? const Color(0xFF8B3A30)
                  : const Color(0xFFF4CDC7),
              foregroundColor: isDark ? AppColors.peach : AppColors.brown,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              minimumSize: const Size(60, 36),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryCOlor = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/firefly.png',
                        height: 300,
                        color: theme.colorScheme.primary,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 36.0),

                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: primaryCOlor),
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),

                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Kindly enter your username'
                            : null,
                      ),

                      const SizedBox(height: 18.0),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: primaryCOlor),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: primaryCOlor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),

                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Kindly enter your password'
                            : null,
                      ),
                      const SizedBox(height: 24.0),

                      FilledButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),

                      const SizedBox(height: 12.0),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              const StadiumBorder(),
                            ),
                            foregroundColor: WidgetStateProperty.all(
                              primaryCOlor,
                            ),
                            overlayColor: WidgetStateColor.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.hovered) ||
                                  states.contains(WidgetState.pressed)) {
                                return isDark
                                    ? AppColors.peach.withOpacity(0.14)
                                    : const Color(0xDDD4CDC7);
                              }
                              return Colors.transparent;
                            }),
                          ),
                          onPressed: () async {
                            final registeredUsername =
                                await Navigator.of(context).push<String>(
                                  MaterialPageRoute(
                                    builder: (_) => RegisterScreen(
                                      onToggleTheme: widget.onToggleTheme,
                                    ),
                                  ),
                                );
                          },
                          child: const Text(
                            'Does not have an account yet? Sign Up now!',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.brightness_medium, size: 28),

                onPressed: widget.onToggleTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

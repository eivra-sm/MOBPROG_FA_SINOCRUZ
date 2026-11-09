import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fa4_reverse_engineering/commons/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const RegisterScreen({super.key, this.onToggleTheme});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://flutter-reverse-engineering-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final rawUsername = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      final userRef = _database.ref('users/$rawUsername');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showAppDialog(
          title: 'Registration failed.',
          message: 'Username already exists',
        );
        return;
      }

      await userRef.set({
        'username': rawUsername,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'createdAt': ServerValue.timestamp,
      });

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firefly $rawUsername added successfully',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: const Color(0xFF392E2C),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.fixed,
        ),
      );

      Navigator.of(context).pop(rawUsername);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      _showAppDialog(
        title: 'Registration Error',
        message: e.toString(),
      );
    }
  }

  Future<void> _showAppDialog({
    required String title,
    required String message,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.brown : const Color.fromARGB(255, 246, 231, 229),
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

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? 'Kindly enter your $label' : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16.0),

                      Image.asset(
                        'assets/firefly.png',
                        height: 300,
                        color: primaryColor,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12.0),

                      Text(
                        'Become a Firefly',
                        style: TextStyle(
                          fontSize: 26,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      TextFormField(
                        controller: _usernameController,
                        maxLength: 50,
                        style: TextStyle(color: primaryColor),
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        validator: (v) => _required(v, 'username'),
                      ),
                      const SizedBox(height: 8.0),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: primaryColor),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: primaryColor,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (v) => _required(v, 'password'),
                      ),
                      const SizedBox(height: 16.0),

                      TextFormField(
                        controller: _firstNameController,
                        maxLength: 50,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(color: primaryColor),
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                        validator: (v) => _required(v, 'first name'),
                      ),
                      const SizedBox(height: 8.0),

                      TextFormField(
                        controller: _lastNameController,
                        maxLength: 50,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(color: primaryColor),
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                        ),
                        validator: (v) => _required(v, 'last name'),
                      ),
                      const SizedBox(height: 20.0),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _register,
                          child: _isLoading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                              : const Text(
                                  'Signup',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                onPressed: widget.onToggleTheme,
                icon: const Icon(Icons.brightness_medium, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

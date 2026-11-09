import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fa4_reverse_engineering/commons/app_colors.dart';

import 'login_screen.dart';
import '../summary/parameter_summary.dart';
import '../summary/supply_summary.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final String username;

  const HomeScreen({super.key, this.username = 'Firefly', this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'Firefly';

  FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://flutter-reverse-engineering-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    try {
      final snapshot = await _database.ref('users/${widget.username}').get();

      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final firstName = data['firstName']?.toString().trim() ?? '';
        final lastName = data['lastName']?.toString().trim() ?? '';

        final fullName = '$firstName $lastName'.trim();

        if (fullName.isNotEmpty && mounted) {
          setState(() {
            userName = fullName;
          });
          return;
        }
      }
      if (mounted) {
        setState(() {
          userName = widget.username;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          userName = widget.username;
        });
      }
    }
  }

  Future<void> _logout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogBackground = isDark
        ? const Color(0xFF322723)
        : const Color(0xFFF7E4E1);
    final textColor = isDark
        ? const Color(0xFFFFDAD5)
        : const Color(0xFF5D3F3B);
    final buttonBackground = isDark
        ? const Color(0xFF73342C)
        : const Color(0xFFFFDAD5);
    final buttonTextColor = isDark
        ? const Color(0xFFFFDAD5)
        : const Color(0xFF73342C);

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        contentPadding: const EdgeInsets.fromLTRB(28, 0, 24, 16),
        title: Text(
          'Logout confirmation',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: textColor, fontSize: 16),
        ),

        actionsPadding: const EdgeInsets.only(right: 24, bottom: 20),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: buttonBackground,
                  foregroundColor: buttonTextColor,
                  shape: const StadiumBorder(),
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(fontSize: 15)),
              ),
              const SizedBox(width: 10),

              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: buttonBackground,
                  foregroundColor: buttonTextColor,
                  shape: const StadiumBorder(),
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Yes', style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ],
      ),
    );
    if (shouldLogout == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LoginScreen(onToggleTheme: widget.onToggleTheme),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: widget.onToggleTheme,
          icon: Icon(Icons.brightness_medium, color: primaryColor, size: 28),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: primaryColor, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParameterSummaryScreen(),
                ),
              );
            },
          ),
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout, color: primaryColor, size: 26),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Hello',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  'You are now one of the Fireflies',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 38),

                Image.asset(
                  'assets/firefly.png',
                  height: 250,
                  color: primaryColor,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 50),

                Center(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.peach
                          : AppColors.brown,
                      foregroundColor: isDark ? AppColors.brown : Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      minimumSize: const Size(180, 42),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupplySummaryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Check for Supplies',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

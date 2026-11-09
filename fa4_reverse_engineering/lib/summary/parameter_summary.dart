import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../commons/app_colors.dart';
import '../commons/firebase_config.dart';
import '../data/new_parameter.dart';

class ParameterItem {
  final String id;
  final String name;
  final String parameterClass;
  final Color color;
  final String colorHex;

  const ParameterItem({
    required this.id,
    required this.name,
    required this.parameterClass,
    required this.color,
    required this.colorHex,
  });

  factory ParameterItem.fromMap(String id, Map<String, dynamic> map) {
    Color parsedColor = const Color(0xFF000000);
    String hexStr = map['colorHex']?.toString() ?? 'FF000000';

    if (map['color'] != null && map['color'] is int) {
      parsedColor = Color(map['color'] as int);
    } else if (map['colorHex'] != null) {
      final cleanHex = hexStr.replaceAll('#', '').replaceAll('0x', '');
      final intVal = int.tryParse(
        cleanHex.length == 6 ? 'FF$cleanHex' : cleanHex,
        radix: 16,
      );
      if (intVal != null) parsedColor = Color(intVal);
    }

    return ParameterItem(
      id: id,
      name: (map['name'] ?? map['parameterName'] ?? 'Unnamed').toString(),
      parameterClass: (map['parameterClass'] ?? map['class'] ?? 'General')
          .toString(),
      color: parsedColor,
      colorHex: hexStr.toUpperCase(),
    );
  }
}

class ParameterSummaryScreen extends StatefulWidget {
  const ParameterSummaryScreen({super.key});

  @override
  State<ParameterSummaryScreen> createState() => _ParameterSummaryScreenState();
}

class _ParameterSummaryScreenState extends State<ParameterSummaryScreen> {
  bool _isLoading = true;
  List<ParameterItem> _parameters = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchParameters();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchParameters() async {
    setState(() => _isLoading = true);

    final url = Uri.parse(
      '${FirebaseConfig.databaseUrl}/${FirebaseConfig.parametersPath}',
    );

    try {
      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200 && response.body != 'null') {
        final data = json.decode(response.body);
        final List<ParameterItem> loaded = [];

        if (data is Map<String, dynamic>) {
          data.forEach((id, val) {
            if (val is Map<String, dynamic>) {
              loaded.add(ParameterItem.fromMap(id, val));
            }
          });
        } else if (data is List) {
          for (var i = 0; i < data.length; i++) {
            if (data[i] != null && data[i] is Map<String, dynamic>) {
              loaded.add(ParameterItem.fromMap(i.toString(), data[i]));
            }
          }
        }
        setState(() {
          _parameters = loaded.reversed.toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _parameters = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog('No Parameter', '');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.peach,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.brown,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: AppColors.brown.withOpacity(0.85),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.peach,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.brown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateAndAddParameter() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewParameter()),
    );
    if (result == true && mounted) {
      _fetchParameters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final filteredParameters = _parameters.where((param) {
      final paramClass = param.parameterClass.toLowerCase();
      return paramClass.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Parameter Setting',
          style: TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: primaryColor, size: 28),
            onPressed: _navigateAndAddParameter,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: primaryColor, fontSize: 17),
                decoration: InputDecoration(
                  hintText: 'Search by Class',
                  hintStyle: TextStyle(
                    color: primaryColor.withOpacity(0.6),
                    fontSize: 17,
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor.withOpacity(0.35),
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 1.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 3.0,
                      ),
                    )
                  : filteredParameters.isEmpty
                  ? Center(
                      child: Text(
                        ' ',
                        style: TextStyle(
                          color: primaryColor.withOpacity(0.6),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredParameters.length,
                      itemBuilder: (context, index) {
                        final param = filteredParameters[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                color: param.color,
                              ),
                              const SizedBox(width: 16),

                              Expanded(
                                child: Text(
                                  param.name,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: primaryColor,
                                  ),
                                ),
                              ),

                              Text(
                                param.parameterClass,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: primaryColor.withOpacity(0.85),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

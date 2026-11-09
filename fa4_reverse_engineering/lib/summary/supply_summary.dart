import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import '../data/new_supply.dart';
import '../chart/supply_chart.dart';

class SupplyItem {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final String categoryName;
  final Color categoryColor;

  const SupplyItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.categoryName,
    required this.categoryColor,
  });

  double get totalPrice => unitPrice * quantity;

  factory SupplyItem.fromMap(String id, Map<String, dynamic> map) {
    Color color = const Color(0xFFE024E0);
    if (map['categoryColor'] != null && map['categoryColor'] is int) {
      color = Color(map['categoryColor'] as int);
    }
    return SupplyItem(
      id: id,
      name: (map['name'] ?? '').toString(),
      quantity: (map['quantity'] is int)
          ? map['quantity'] as int
          : int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
      unitPrice: (map['unitPrice'] is num)
          ? (map['unitPrice'] as num).toDouble()
          : double.tryParse(map['unitPrice']?.toString() ?? '0') ?? 0.0,
      categoryName: (map['category'] ?? 'Melee').toString(),
      categoryColor: color,
    );
  }
}

class SupplySummaryScreen extends StatefulWidget {
  const SupplySummaryScreen({super.key});

  @override
  State<SupplySummaryScreen> createState() => _SupplySummaryScreenState();
}

class _SupplySummaryScreenState extends State<SupplySummaryScreen> {
  bool _isLoading = false;
  List<SupplyItem> _supplies = [];

  @override
  void initState() {
    super.initState();
    _fetchSupplies();
  }

  Future<void> _fetchSupplies() async {
    setState(() => _isLoading = true);

    final url = Uri.parse(
      '${FirebaseConfig.databaseUrl}/${FirebaseConfig.suppliesPath}',
    );

    try {
      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200 && response.body != 'null') {
        final data = json.decode(response.body);
        final List<SupplyItem> loaded = [];

        if (data is Map) {
          data.forEach((key, val) {
            if (val is Map) {
              loaded.add(
                SupplyItem.fromMap(
                  key.toString(),
                  Map<String, dynamic>.from(val),
                ),
              );
            }
          });
        }
        setState(() {
          _supplies = loaded.reversed.toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _supplies = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateAndAddSupply() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const NewSupply()),
    );
    if (result == true && mounted) {
      _fetchSupplies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF73342C)
        : const Color(0xFFFFD9D3);
    final primaryTextColor = isDark
        ? const Color(0xFFFFDAD5)
        : const Color(0xFF4A2E2B);
    final itemCardBg = isDark
        ? const Color(0xFF5D3F3B)
        : const Color(0xFFFBE5E1);
    final itemCardBorder = isDark
        ? Colors.transparent
        : const Color(0xFFF0CBC6);

    final List<SupplyBarItem> chartItems = _supplies.map((item) {
      return SupplyBarItem(
        value: item.totalPrice,
        categoryColor: item.categoryColor,
      );
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          tooltip: 'Back',
        ),
        title: Text(
          'Supply Manager',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _navigateAndAddSupply,
            icon: Icon(Icons.add, color: primaryTextColor),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SupplyChart(isLoading: _isLoading, items: chartItems, height: 200),

            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryTextColor),
                    )
                  : Scrollbar(
                      thumbVisibility: true,
                      radius: const Radius.circular(8),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 6.0,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _supplies.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final item = _supplies[index];
                          final formattedPrice = item.unitPrice % 1 == 0
                              ? item.unitPrice.toInt().toString()
                              : item.unitPrice.toStringAsFixed(2);
                          final formattedTotal = item.totalPrice % 1 == 0
                              ? item.totalPrice.toInt().toString()
                              : item.totalPrice.toStringAsFixed(2);

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              color: itemCardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: itemCardBorder,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryTextColor,
                                          letterSpacing: 0.1,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),

                                      Text(
                                        '\$$formattedPrice X ${item.quantity} = \$$formattedTotal',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: primaryTextColor.withOpacity(
                                            0.85,
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: item.categoryColor,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.categoryName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

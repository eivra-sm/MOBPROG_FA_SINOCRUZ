import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../commons/app_colors.dart';

class FirebaseConfig {
  static const String databaseUrl =
      'https://flutter-reverse-engineering-default-rtdb.asia-southeast1.firebasedatabase.app';

  static const String usersPath = 'users.json';
  static const String suppliesPath = 'supplies.json';
  static const String parametersPath = 'parameters.json';
}

class SupplyCategoryItem {
  final String id;
  final String name;
  final Color color;

  const SupplyCategoryItem({
    required this.id,
    required this.name,
    required this.color,
  });

  factory SupplyCategoryItem.fromMap(String id, dynamic data) {
    if (data is String) {
      return SupplyCategoryItem(
        id: id,
        name: data,
        color: const Color(0xFF00E5FF),
      );
    }
    final map = Map<String, dynamic>.from(data as Map);
    Color categoryColor = const Color(0xFF00E5FF);

    if (map['color'] != null && map['color'] is num) {
      categoryColor = Color((map['color'] as num).toInt());
    } else if (map['colorHex'] != null && map['colorHex'] is String) {
      final hexStr = (map['colorHex'] as String)
          .replaceAll('#', '')
          .replaceAll('0x', '');
      final val = int.tryParse(
        hexStr.length == 6 ? 'FF$hexStr' : hexStr,
        radix: 16,
      );
      if (val != null) categoryColor = Color(val);
    }

    return SupplyCategoryItem(
      id: id,
      name: (map['name'] ?? map['parameterName'] ?? 'General').toString(),
      color: categoryColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplyCategoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class NewSupply extends StatefulWidget {
  const NewSupply({super.key});

  @override
  State<NewSupply> createState() => _NewSupplyState();
}

class _NewSupplyState extends State<NewSupply> {
  final _nameController = TextEditingController();
  final _unitPriceController = TextEditingController(text: '1.00');
  final _quantityController = TextEditingController(text: '1');
  final _quantityFocusNode = FocusNode();

  int _quantity = 1;

  SupplyCategoryItem? _selectedCategory;
  List<SupplyCategoryItem> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSaving = false;

  String? _nameError;
  String? _priceError;

  final List<SupplyCategoryItem> _fallbackCategories = const [
    SupplyCategoryItem(id: 'melee', name: 'MELLE', color: Color(0xFFE024E0)),
    SupplyCategoryItem(
      id: 'assult',
      name: 'ASSAULT RIFLE',
      color: Color(0xFF8CFF32),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();

    _quantityFocusNode.addListener(() {
      if (!_quantityFocusNode.hasFocus) {
        final parsed = int.tryParse(_quantityController.text) ?? 0;
        if (parsed <= 0) {
          setState(() {
            _quantity = 1;
            _quantityController.text = '1';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitPriceController.dispose();
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    final url = Uri.parse(
      '${FirebaseConfig.databaseUrl}/${FirebaseConfig.parametersPath}',
    );

    try {
      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200 && response.body != 'null') {
        final data = json.decode(response.body);
        final List<SupplyCategoryItem> loaded = [];

        if (data is Map) {
          data.forEach((key, val) {
            if (val is Map) {
              loaded.add(SupplyCategoryItem.fromMap(key.toString(), val));
            }
          });
        }
        setState(() {
          _categories = loaded.isNotEmpty
              ? loaded
              : List.from(_fallbackCategories);
          _selectedCategory = _categories.first;
          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _categories = List.from(_fallbackCategories);
          _selectedCategory = _categories.first;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categories = List.from(_fallbackCategories);
        _selectedCategory = _categories.first;
        _isLoadingCategories = false;
      });
    }
  }

  void _showErrorDialog(String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogBg = isDark ? const Color(0xFF5D3F3B) : AppColors.peach;
    final dialogText = isDark ? const Color(0xFFFFDAD5) : AppColors.brown;
    final okButtonBg = isDark
        ? const Color(0xFFFFDAD5)
        : const Color(0xFF7E413B);
    final okButtonText = isDark ? const Color(0xFF73342C) : Colors.white;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(
            color: dialogText,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: dialogText.withOpacity(0.85), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              backgroundColor: okButtonBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            child: Text(
              'OK',
              style: TextStyle(
                color: okButtonText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSupply() async {
    final nameText = _nameController.text.trim();
    final priceText = _unitPriceController.text.trim();

    setState(() {
      _nameError = nameText.isEmpty ? 'Input an item name' : null;
      _priceError = priceText.isEmpty ? 'Input an amount' : null;
    });

    if (nameText.isEmpty || priceText.isEmpty) {
      return;
    }

    int currentQty = int.tryParse(_quantityController.text) ?? 1;
    if (currentQty <= 0) {
      currentQty = 1;
      _quantityController.text = '1';
    } else if (currentQty > 100) {
      currentQty = 100;
      _quantityController.text = '100';
    }
    _quantity = currentQty;

    final parsedPrice = double.tryParse(priceText);

    if (parsedPrice == null || parsedPrice <= 0 ) {
      setState(() => _isSaving = true);
      return;
    }

    setState(() => _isSaving = true);

    final supplyPayload = {
      'name': _nameController.text,
      'quantity': _quantity,
      'unitPrice': parsedPrice,
      'rawUnitPrice': _unitPriceController.text,
      'category': _selectedCategory?.name ?? 'MELEE',
      'categoryColor':
          _selectedCategory?.color.value ?? const Color(0xFF00E5FF).value,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final url = Uri.parse(
      '${FirebaseConfig.databaseUrl}/${FirebaseConfig.suppliesPath}',
    );

    try {
      final response = await http.post(url, body: json.encode(supplyPayload));
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        setState(() => _isSaving = false);
        _showErrorDialog('Error', 'Failed to save supply');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showErrorDialog('Error', 'Failed to connect to Firebase');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF73342C)
        : const Color(0xFFFFDAD5);
    final primaryTextColor = isDark
        ? const Color(0xFFFFDAD5)
        : const Color(0xFF4A2E2B);
    final borderColor = isDark
        ? const Color(0xFFFFDAD5).withOpacity(0.4)
        : const Color(0xFF75372E);
    final focusedBorderColor = isDark
        ? const Color(0xFFFFDAD5)
        : const Color(0xFF75372E);
    final errorColor = isDark
        ? const Color(0xFFFFB4AB)
        : const Color(0xFFBA1A1A);

    final dropdownBg = isDark
        ? const Color(0xFF5D3F3B)
        : const Color(0xFFFBE5E1);
    final buttonBgColor = isDark
        ? const Color(0xFFFFDAD5)
        : const Color(0xFF7E413B);
    final buttonTextColor = isDark ? const Color(0xFF73342C) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          tooltip: 'Back',
        ),
        title: Text(
          'Add a new supply',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
                style: TextStyle(color: primaryTextColor, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  labelStyle: TextStyle(
                    color: _nameError != null ? errorColor : primaryTextColor,
                    fontSize: 16,
                  ),
                  errorText: _nameError,
                  errorStyle: TextStyle(
                    color: errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: focusedBorderColor,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: errorColor, width: 1.2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: errorColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Item Quantity',
                  labelStyle: TextStyle(color: primaryTextColor, fontSize: 16),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: focusedBorderColor,
                      width: 1.5,
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 44,
                  child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      icon: Icon(
                        Icons.remove,
                        color: primaryTextColor,
                        size: 24,
                      ),
                      onPressed: () {
                        int current =
                            int.tryParse(_quantityController.text) ?? 1;
                        if (current > 1) {
                          current--;

                          setState(() {
                            _quantity = current;
                            _quantityController.text = '$current';
                          });
                        }
                      },
                    ),

                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        focusNode: _quantityFocusNode,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          if (val.isEmpty) return;
                          final num = int.tryParse(val);
                          if (num != null) {
                            if (num > 100) {
                              setState(() {
                                _quantity = 100;
                                _quantityController.text = '100';
                                _quantityController.selection =
                                    const TextSelection.collapsed(offset: 3);
                              });
                            } else if (num > 0) {
                              _quantity = num;
                            }
                          }
                        },
                        onEditingComplete: () {
                          final parsed =
                              int.tryParse(_quantityController.text) ?? 0;
                          if (parsed <= 0) {
                            setState(() {
                              _quantity = 1;
                              _quantityController.text = '1';
                            });
                          }
                          _quantityFocusNode.unfocus();
                        },
                      ),
                    ),

                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      icon: Icon(Icons.add, color: primaryTextColor, size: 24),
                      onPressed: () {
                        int current =
                            int.tryParse(_quantityController.text) ?? 1;
                        if (current < 100) {
                          current++;

                          setState(() {
                            _quantity = current;
                            _quantityController.text = '$current';
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 18),

              TextField(
                controller: _unitPriceController,
                keyboardType: TextInputType.text,
                onChanged: (_) {
                  if (_priceError != null) setState(() => _priceError = null);
                },
                style: TextStyle(color: primaryTextColor, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Unit Price',
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(color: primaryTextColor, fontSize: 16),
                  labelStyle: TextStyle(
                    color: _priceError != null ? errorColor : primaryTextColor,
                    fontSize: 16,
                  ),
                  errorText: _priceError,
                  errorStyle: TextStyle(
                    color: errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: focusedBorderColor,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: errorColor, width: 1.2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: errorColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Supply Category',
                  labelStyle: TextStyle(
                    color: primaryTextColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: focusedBorderColor,
                      width: 1.5,
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 44,
                  child: _isLoadingCategories
                      ? Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryTextColor,
                            ),
                          ),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<SupplyCategoryItem>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: primaryTextColor,
                            ),
                            dropdownColor: dropdownBg,
                            items: _categories.map((cat) {
                              return DropdownMenuItem<SupplyCategoryItem>(
                                value: cat,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: cat.color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    Text(
                                      cat.name,
                                      style: TextStyle(
                                        color: primaryTextColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (cat) {
                              if (cat != null) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              }
                            },
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSupply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBgColor,
                    disabledBackgroundColor: AppColors.brown.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: buttonTextColor,
                          ),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            color: buttonTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

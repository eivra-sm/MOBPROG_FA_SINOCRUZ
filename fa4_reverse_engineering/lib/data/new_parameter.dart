import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../commons/app_colors.dart';
import '../commons/firebase_config.dart';

class NewParameter extends StatefulWidget {
  const NewParameter({super.key});

  @override
  State<NewParameter> createState() => _NewParameterState();
}

class _NewParameterState extends State<NewParameter> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _classController = TextEditingController();

  Color _selectedColor = const Color(0xFF000000);
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    super.dispose();
  }

  String get _hexColorString {
    return _selectedColor.value.toRadixString(16).toUpperCase().padLeft(8, '0');
  }

  void _resetForm() {
    _nameController.clear();
    _classController.clear();

    setState(() {
      _selectedColor = const Color(0xFF000000);
    });
  }

  Future<void> _addParameter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse(
      '${FirebaseConfig.databaseUrl}/${FirebaseConfig.parametersPath}',
    );
    final payload = {
      'name': _nameController.text.trim(),
      'parameterClass': _classController.text.trim(),
      'color': _selectedColor.value,
      'colorHex': _hexColorString,
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(url, body: json.encode(payload));
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        setState(() => _isLoading = false);
        _showErrorDialog('Failed to add Parameter.', 'Internal server error');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to add Parameter.', 'Internal server error');
    }
  }

  void _showErrorDialog(String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogBg = isDark ? const Color(0xFF5D3F3B) : AppColors.peach;
    final dialogText = isDark ? const Color(0xFFFFDAD5) : AppColors.brown;

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
          style: TextStyle(
            color: dialogText.withOpacity(0.85),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF73342C) : AppColors.peach,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? const Color(0xFF73342C) : const Color(0xFFFFDAD5);
    final primaryTextColor = isDark ? const Color(0xFFFFDAD5) : const Color(0xFF4A2E2B);
    final errorColor = isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A);
    
    final buttonBgColor = isDark ? const Color(0xFFFFDAD5) : const Color(0xFF7E413B);
    final buttonTextColor = isDark ? const Color(0xFF73342C) : Colors.white;

    InputDecoration buildInputDecoration({required String label}) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        fillColor: Colors.transparent,
        filled: false,
        errorStyle: TextStyle(
          color: errorColor,

          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        counterStyle: TextStyle(
          color: primaryTextColor.withOpacity(0.7),
          fontSize: 12,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primaryTextColor.withOpacity(0.7), width: 1.2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primaryTextColor, width: 2.0),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: errorColor, width: 1.2),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: errorColor, width: 2.0),
        ),
      );
    }

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
          'Add a new parameter',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  maxLength: 50,
                  style: TextStyle(color: primaryTextColor, fontSize: 16),
                  decoration: buildInputDecoration(label: 'Parameter Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Must be between 1 and 50 Characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _classController,
                            maxLength: 50,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 16,
                            ),
                            decoration: buildInputDecoration(
                              label: 'Parameter Class',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Must be between 1 and 50 Characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ColorWheelPicker(
                            size: 200,
                            selectedColor: _selectedColor,
                            onColorChanged: (newColor) {
                              setState(() => _selectedColor = newColor);
                            },
                          ),
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _selectedColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),

                              Text(
                                _hexColorString,
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _resetForm,
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryTextColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              ElevatedButton(
                                onPressed: _isLoading ? null : _addParameter,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonBgColor,
                                  foregroundColor: buttonTextColor,
                                  elevation: 0,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 12,
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: buttonTextColor,
                                        ),
                                      )
                                    : const Text(
                                        'Add Parameter',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ColorWheelPicker extends StatefulWidget {
  final double size;
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const ColorWheelPicker({
    super.key,
    required this.size,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  State<ColorWheelPicker> createState() => _ColorWheelPickerState();
}

class _ColorWheelPickerState extends State<ColorWheelPicker> {
  late Offset _thumbPosition;

  @override
  void initState() {
    super.initState();
    _thumbPosition = Offset(widget.size / 2, widget.size / 2);
  }

  void _handleTouch(Offset localPos) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final radius = widget.size / 2;

    Offset pos = localPos;
    double sat = distance / radius;
    if (distance > radius) {
      pos = Offset(
        center.dx + (dx / distance) * radius,
        center.dy + (dy / distance) * radius,
      );
      sat = 1.0;
    }
    double angle = atan2(dy, dx) * 180 / pi;
    if (angle < 0) angle += 360;

    final color = HSVColor.fromAHSV(
      1.0,
      angle,
      sat.clamp(0.0, 1.0),
      1.0,
    ).toColor();

    setState(() {
      _thumbPosition = pos;
    });
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        onPanDown: (details) => _handleTouch(details.localPosition),
        onPanUpdate: (details) => _handleTouch(details.localPosition),
        child: Stack(
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _ColorWheelPainter(),
            ),
            Positioned(
              left: _thumbPosition.dx - 12,
              top: _thumbPosition.dy - 12,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const colors = [
      Color(0xFFFF0000),
      Color(0xFFFFFF00),
      Color(0xFF00FF00),
      Color(0xFF00FFFF),
      Color(0xFF0000FF),
      Color(0xFFFF00FF),
      Color(0xFFFF0000),
    ];

    final sweepGradient = SweepGradient(colors: colors);
    final sweepPaint = Paint()
      ..shader = sweepGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, sweepPaint);

    final radialPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.white, Colors.transparent],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, radialPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

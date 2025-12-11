import 'package:flutter/material.dart';
import 'package:timecountdown/Theme/AppColors.dart';

class Textfieldcomponent extends StatefulWidget {
  final int maxLength;
  final String? initialValue;
  final String hintText;
  final ValueChanged<String> onTextChanged;
  final FocusNode focusNode;

  const Textfieldcomponent({
    Key? key,
    required this.initialValue,
    required this.maxLength,
    required this.hintText,
    required this.onTextChanged,
    required this.focusNode,
  }) : super(key: key);

  @override
  State<Textfieldcomponent> createState() => _TextfieldcomponentState();
}

class _TextfieldcomponentState extends State<Textfieldcomponent> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() {
      setState(() {
        widget.onTextChanged(_controller.text);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      controller: _controller,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      maxLength: widget.maxLength,
      maxLines: 2,
      cursorColor: AppColors.accentPrimary,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: AppRadius.mdAll,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width: 1),
          borderRadius: AppRadius.mdAll,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentPrimary, width: 2),
          borderRadius: AppRadius.mdAll,
        ),
        counterStyle: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 12,
        ),
      ),
    );
  }
}

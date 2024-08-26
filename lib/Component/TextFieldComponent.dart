import 'package:flutter/material.dart';

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
  //final TextEditingController _controller = TextEditingController();
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
        color: Colors.white,
      ),
      maxLength: widget.maxLength,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: 'Enter Title',
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(20),
        ),
        counterStyle:
            const TextStyle(color: Colors.white), // Change counter text color
        // suffix: Padding(
        //   padding: const EdgeInsets.only(right: 10.0),
        //   child: Text(
        //     '$_remainingChars',
        //     style: const TextStyle(color: Colors.white),
        //   ),
        // ),
      ),
    );
  }
}

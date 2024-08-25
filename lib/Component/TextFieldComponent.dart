import 'package:flutter/material.dart';

class Textfieldcomponent extends StatefulWidget {
  final int maxLength;
  final String? initialValue;
  final String hintText;
  final ValueChanged<String> onTextChanged;

  const Textfieldcomponent({
    Key? key,
    required this.initialValue,
    required this.maxLength,
    required this.hintText,
    required this.onTextChanged,
  }) : super(key: key);

  @override
  State<Textfieldcomponent> createState() => _TextfieldcomponentState();
}

class _TextfieldcomponentState extends State<Textfieldcomponent> {
  final TextEditingController _controller = TextEditingController();
  // int _remainingChars = 0;

  @override
  void initState() {
    super.initState();
    //_remainingChars = widget.maxLength;
    _controller.addListener(() {
      setState(() {
        // _remainingChars = widget.maxLength - _controller.text.length;
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

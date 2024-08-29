import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const CustomListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: title == 'Buy Premium' ? Colors.amber : Colors.white,
        size: 30,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      onTap: onTap,
    );
  }
}

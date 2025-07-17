import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isPremiumFeature;

  const CustomListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isPremiumFeature = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: title == 'Buy Premium' ? Colors.amber : Colors.white,
        size: 30,
      ),
      title: Row(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          if (isPremiumFeature) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

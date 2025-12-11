import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class VerticalSettingsBar extends StatefulWidget {
  @override
  _VerticalSettingsBarState createState() => _VerticalSettingsBarState();
}

class _VerticalSettingsBarState extends State<VerticalSettingsBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Start animation when widget is created
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveImageOnLocal() async {
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);

    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        String fileName =
            DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
        widgetStateProvider.isLoading = true;
        final directory = await getApplicationDocumentsDirectory();
        // Create a new file in the documents directory
        final File newImage = File('${directory.path}/$fileName');

        await File(pickedFile.path).copy(newImage.path);

        widgetStateProvider.image = newImage.path;
        widgetStateProvider.isLoading = false;

        print("image path: ${pickedFile.path}");
      }
    } catch (e) {
      // Handle errors gracefully
      print("Error selecting image: $e");
      widgetStateProvider.isLoading = false;
    }
  }

  Widget _buildAnimatedSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required int index,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 1 + (index * 0.1)),
          end: const Offset(0, 0),
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.8 + (index * 0.1),
            curve: Curves.elasticOut,
          ),
        )),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.green,
                  size: 34,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widgetStateProvider = Provider.of<RenderedWidgetProvider>(context);

    return Positioned(
      bottom:
          150, // Moved up to maintain alignment with the new bottom bar position (100 + 50)
      right: 20, // Align to the right where settings button is
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimatedSettingItem(
                icon: Icons.light_mode_sharp,
                title: 'Dark Mode',
                onTap: () {
                  widgetStateProvider.renderedWidget = "dim";
                },
                index: 0,
              ),
              _buildAnimatedSettingItem(
                icon: Icons.add_photo_alternate,
                title: 'Background',
                onTap: () async {
                  await _saveImageOnLocal();
                },
                index: 1,
              ),
              _buildAnimatedSettingItem(
                icon: Icons.alarm,
                title: 'Reminder',
                onTap: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Reminder feature available soon in next update :)'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

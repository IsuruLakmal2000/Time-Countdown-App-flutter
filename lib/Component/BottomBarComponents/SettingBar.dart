import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class SettingsBar extends StatefulWidget {
  const SettingsBar({Key? key}) : super(key: key);

  @override
  State<SettingsBar> createState() => _SettingsBarState();
}

class _SettingsBarState extends State<SettingsBar> with SingleTickerProviderStateMixin {
  bool _isSettingsOpen = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _isSettingsOpen = true; // Start with settings open when this widget is created
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: const Offset(0, 0)).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    // Start the animation immediately
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> SaveImageOnLocal() async {
    final widgetStateProvider = Provider.of<RenderedWidgetProvider>(context, listen: false);
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
        widgetStateProvider.isLoading = true;
        final directory = await getApplicationDocumentsDirectory();
        final File newImage = File('${directory.path}/$fileName');
        await File(pickedFile.path).copy(newImage.path);
        widgetStateProvider.image = newImage.path;
        widgetStateProvider.isLoading = false;
        print("image path: ${pickedFile.path}");
      }
    } catch (e) {
      print("Error selecting image: $e");
      widgetStateProvider.isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 140, // Position above the settings button (50 + 60 for button height)
      right: 30,   // Move more to the left to align with tick button center
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align to match tick button
        mainAxisSize: MainAxisSize.min,
          children: [
            // Only show menu items - tick button is handled by BottomWidgetBar
            if (_isSettingsOpen)
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // Center align menu items
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSettingItem(
                      context: context,
                      icon: Icons.light_mode_sharp,
                      title: 'Dark Mode',
                      onTap: () {
                        Provider.of<RenderedWidgetProvider>(context, listen: false).renderedWidget = "dim";
                      },
                      index: 0,
                    ),
                    _buildSettingItem(
                      context: context,
                      icon: Icons.add_photo_alternate,
                      title: 'Background',
                      onTap: () async {
                        await SaveImageOnLocal();
                        Provider.of<RenderedWidgetProvider>(context, listen: false).renderedWidget = "none";
                      },
                      index: 1,
                    ),
                    _buildSettingItem(
                      context: context,
                      icon: Icons.alarm,
                      title: 'Reminder',
                      onTap: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reminder feature available soon in next update :)'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Provider.of<RenderedWidgetProvider>(context, listen: false).renderedWidget = "none";
                      },
                      index: 2,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required int index,
  }) {
    return Container(
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
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/BottomBarComponents/ReminderSettingSheet.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class SettingsBar extends StatefulWidget {
  const SettingsBar({Key? key}) : super(key: key);

  @override
  State<SettingsBar> createState() => _SettingsBarState();
}

class _SettingsBarState extends State<SettingsBar>
    with SingleTickerProviderStateMixin {
  bool _isSettingsOpen = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _isSettingsOpen =
        true; // Start with settings open when this widget is created
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    // Changed slide animation to coming from right to left since it's horizontal
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.5, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
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
      bottom:
          80, // Adjusted to 80 for precise vertical centering (Icon center ~108px)
      right: 90, // Move to the left of the close button
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Only show menu items - tick button is handled by BottomWidgetBar
          if (_isSettingsOpen)
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Row(
                  // Changed Column to Row
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSettingItem(
                      context: context,
                      icon: Icons.light_mode_sharp,
                      title: 'Dim',
                      onTap: () {
                        Provider.of<RenderedWidgetProvider>(context,
                                listen: false)
                            .renderedWidget = "dim";
                      },
                      index: 0,
                    ),
                    _buildSettingItem(
                      context: context,
                      icon: Icons.add_photo_alternate,
                      title: 'Image',
                      onTap: () async {
                        await SaveImageOnLocal();
                        Provider.of<RenderedWidgetProvider>(context,
                                listen: false)
                            .renderedWidget = "none";
                      },
                      index: 1,
                    ),
                    _buildSettingItem(
                      context: context,
                      icon: Icons.alarm,
                      title: 'Reminder',
                      onTap: () async {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Color.fromARGB(255, 33, 33, 33),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => const ReminderSettingSheet(),
                        );

                        Provider.of<RenderedWidgetProvider>(context,
                                listen: false)
                            .renderedWidget = "none";
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
      margin: const EdgeInsets.only(
          right: 12.0), // Changed bottom margin to right margin
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 70, // Fixed width for uniformity
            height: 70, // Fixed height for uniformity
            padding: const EdgeInsets.all(8), // Reduced padding
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

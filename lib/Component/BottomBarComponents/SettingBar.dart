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
      bottom: 32,
      right: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isSettingsOpen)
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
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
                      // Close button integrated into the settings bar
                      _buildSettingItem(
                        context: context,
                        icon: Icons.check_rounded,
                        title: 'Close',
                        onTap: () {
                          Provider.of<RenderedWidgetProvider>(context,
                                  listen: false)
                              .renderedWidget = "none";
                        },
                        index: 3,
                        isCloseButton: true,
                      ),
                    ],
                  ),
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
    bool isCloseButton = false,
  }) {
    return Container(
      margin: EdgeInsets.only(right: isCloseButton ? 0 : 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 65,
            height: 65,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCloseButton
                    ? [
                        const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.3),
                        const Color.fromARGB(255, 255, 0, 119).withValues(alpha: 0.3),
                      ]
                    : [
                        const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.15),
                        const Color.fromARGB(255, 255, 0, 119).withValues(alpha: 0.15),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCloseButton
                    ? const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.6)
                    : const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.4),
                width: isCloseButton ? 2.0 : 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: isCloseButton ? 28 : 26,
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCloseButton ? 9.5 : 9,
                    fontWeight: isCloseButton ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: 0.3,
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

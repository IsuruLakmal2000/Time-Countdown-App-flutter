import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Services/BackupService.dart';

import 'package:timecountdown/Pages/PremiumPage/PremiumPage.dart';
import 'package:timecountdown/Pages/MainPages/PrivacyPolicy.dart';
import 'package:timecountdown/Pages/SideBar/CustomListTile.dart';
import 'package:timecountdown/Pages/WidgetPages/WidgetSettingsPage.dart';
import 'package:timecountdown/Providers/PremiumProvider.dart';
import 'package:timecountdown/Providers/UserProvider.dart';
import 'package:url_launcher/url_launcher.dart';

Widget SideBar(BuildContext context, dynamic user) {
  final userProvider = context.watch<UserProvider>();
  final isPremium = context.watch<PremiumProvider>().isPremium;

  return Drawer(
    child: Stack(
      children: [
        // Background image
        Image.asset(
          'assets/Images/jym.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Color filter
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(1),
                Colors.black.withOpacity(0.96),
                Colors.black.withOpacity(0.93),
                Colors.black.withOpacity(0.94),
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
        ),
        // Sidebar content
        Material(
          color: Colors.transparent,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 200,
                      child: DrawerHeader(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_circle,
                              size: 70,
                              color: Colors.white,
                            ),
                            Text(
                              user?.displayName ?? 'User',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 0, 255),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user?.email ?? 'email@xyz.com',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            isPremium
                                ? Text(
                                    'Premium User',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    '${userProvider.userData?.countdownCount ?? 0}/5 countdowns used',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    CustomListTile(
                      icon: Icons.home,
                      title: 'Home',
                      onTap: () => {},
                    ),
                    if (!isPremium)
                      CustomListTile(
                        icon: Icons.workspace_premium,
                        title: 'Buy Premium',
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PremiumPage(),
                            ),
                          ),
                        },
                      ),
                    CustomListTile(
                      icon: Icons.star,
                      title: 'Rate Us!',
                      onTap: () async {
                        String url;
                        if (Theme.of(context).platform ==
                            TargetPlatform.android) {
                          url =
                              'https://play.google.com/store/apps/details?id=com.example.app'; // Example Play Store link
                        } else if (Theme.of(context).platform ==
                            TargetPlatform.iOS) {
                          url =
                              'https://apps.apple.com/app/id123456789'; // Example App Store link
                        } else {
                          url = 'https://example.com'; // Fallback link
                        }
                        final Uri uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    CustomListTile(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyPage()),
                        ),
                      },
                    ),
                    // Backup Data - always visible, premium check inside
                    CustomListTile(
                      icon: Icons.backup,
                      title: 'Backup Data',
                      isPremiumFeature: !isPremium,
                      onTap: () async {
                        try {
                          await BackupService.createBackup(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Backup failed: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    // Widget Settings
                    CustomListTile(
                      icon: Icons.settings_applications,
                      title: 'Widget Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WidgetSettingsPage(),
                          ),
                        );
                      },
                    ),
                    // Import Backup - always visible, premium check inside
                    CustomListTile(
                      icon: Icons.restore,
                      title: 'Import Backup',
                      isPremiumFeature: !isPremium,
                      onTap: () async {
                        try {
                          await BackupService.importBackup(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Import failed: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

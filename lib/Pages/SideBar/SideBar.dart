import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Services/BackupService.dart';
import 'package:timecountdown/Theme/AppColors.dart';

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
    backgroundColor: AppColors.background,
    child: SafeArea(
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              children: [
                // Avatar with gradient border
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.accentGradient,
                  ),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 36,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // User Name
                Text(
                  user?.displayName ?? 'Welcome',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  user?.email ?? 'Countdown Timer',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPremium
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.surfaceLight,
                    borderRadius: AppRadius.xlAll,
                    border: Border.all(
                      color: isPremium
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPremium ? Icons.star_rounded : Icons.timer_outlined,
                        size: 16,
                        color:
                            isPremium ? AppColors.success : AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPremium
                            ? 'Premium User'
                            : '${userProvider.userData?.countdownCount ?? 0}/5 countdowns',
                        style: TextStyle(
                          color:
                              isPremium ? AppColors.success : AppColors.warning,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: AppColors.border, height: 1),
          ),
          const SizedBox(height: 8),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                CustomListTile(
                  icon: Icons.home_rounded,
                  title: 'Home',
                  onTap: () => Navigator.pop(context),
                ),
                if (!isPremium)
                  CustomListTile(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Buy Premium',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PremiumPage(),
                        ),
                      );
                    },
                  ),
                CustomListTile(
                  icon: Icons.widgets_rounded,
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

                // Section Divider
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Divider(color: AppColors.border, height: 1),
                ),

                CustomListTile(
                  icon: Icons.backup_rounded,
                  title: 'Backup Data',
                  isPremiumFeature: !isPremium,
                  onTap: () async {
                    try {
                      await BackupService.createBackup(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Backup failed: ${e.toString()}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),
                CustomListTile(
                  icon: Icons.restore_rounded,
                  title: 'Import Backup',
                  isPremiumFeature: !isPremium,
                  onTap: () async {
                    try {
                      await BackupService.importBackup(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Import failed: ${e.toString()}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),

                // Section Divider
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Divider(color: AppColors.border, height: 1),
                ),

                CustomListTile(
                  icon: Icons.star_rounded,
                  title: 'Rate Us',
                  onTap: () async {
                    String url;
                    if (Theme.of(context).platform == TargetPlatform.android) {
                      url =
                          'https://play.google.com/store/apps/details?id=com.example.app';
                    } else if (Theme.of(context).platform ==
                        TargetPlatform.iOS) {
                      url = 'https://apps.apple.com/app/id123456789';
                    } else {
                      url = 'https://example.com';
                    }
                    final Uri uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                CustomListTile(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

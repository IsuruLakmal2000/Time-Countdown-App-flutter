import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/FirebaseServices/FirebaseSerives.dart';

import 'package:timecountdown/Pages/PremiumPage/PremiumPage.dart';
import 'package:timecountdown/Pages/SideBar/CustomListTile.dart';
import 'package:timecountdown/Providers/UserProvider.dart';
import 'package:url_launcher/url_launcher.dart';

Widget SideBar(BuildContext context, User? user, Function() signOut) {
  final userProvider = context.watch<UserProvider>();
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
                            Text(
                              '${userProvider.userData?.countdownCount}/3 countdowns used',
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
                        String url = await getRatingUrl();
                        print('Rating URL: $url');
                        final Uri uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode
                                  .externalApplication); // Opens in the default browser
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    CustomListTile(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                      onTap: () => {},
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  CustomListTile(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    onTap: () => {signOut()},
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

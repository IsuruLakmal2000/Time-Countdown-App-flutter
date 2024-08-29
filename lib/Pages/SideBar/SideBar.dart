import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timecountdown/Pages/SideBar/CustomListTile.dart';

Widget SideBar(User? user, Function() signOut) {
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
                Colors.black.withOpacity(0.92),
                Colors.black.withOpacity(0.91),
                Colors.black.withOpacity(0.9),
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
                    DrawerHeader(
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
                        ],
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
                      onTap: () => {},
                    ),
                    CustomListTile(
                      icon: Icons.star,
                      title: 'Rate Us!',
                      onTap: () => {},
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

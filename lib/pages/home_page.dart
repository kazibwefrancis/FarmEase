// ignore_for_file: prefer_const_constructors

import 'package:farm_ease/pages/report.dart';
import 'package:farm_ease/pages/cow_management_screen.dart'; // Import the cow management screen
import 'package:farm_ease/pages/explore_page.dart';
import 'package:farm_ease/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:badges/badges.dart' as badges;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List of pages for the BottomNavigationBar
  final pages = [
    const ExplorePage(),
    const CowManagementScreen(), // Replace ServicesPage with CowManagementScreen
    const ReportPage(),
    const ProfilePage(),
  ];

  int currentIndex = 0; // Index for the selected tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer for additional navigation options
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FARMEASE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Your farming assistant",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.cabin),
              title: Text('Cow Management'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CowManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Add your settings page route here
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('App Version'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Add your app version page route here
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Add your help & support page route here
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Add your logout functionality here
              },
            ),
          ],
        ),
      ),

      // AppBar
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              "Welcome to FARMEASE",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton.filledTonal(
              onPressed: () {},
              icon: badges.Badge(
                badgeContent: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                badgeStyle: badges.BadgeStyle(
                  badgeColor: Colors.green,
                ),
                position: badges.BadgePosition.topEnd(top: -15, end: -12),
                child: const Icon(IconlyBroken.notification),
              ),
            ),
          ),
        ],
      ),

      // Body: Display the selected page
      body: pages[currentIndex],

      // BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.home),
            activeIcon: Icon(IconlyBold.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.work),
            activeIcon: Icon(IconlyBold.work),
            label: 'Cattle', // This now points to CowManagementScreen
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.scan),
            activeIcon: Icon(IconlyBold.scan),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.profile),
            activeIcon: Icon(IconlyBold.profile),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

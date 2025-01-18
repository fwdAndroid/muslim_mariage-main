import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muslim_mariage/screens/main/pages/home_page.dart';
import 'package:muslim_mariage/screens/main/pages/message_page.dart';
import 'package:muslim_mariage/screens/main/pages/setting_page.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomePage(), // Replace with your screen widgets
    const MessagePage(),

    const SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          final shouldPop = await _showExitDialog(context);
          return shouldPop ?? false;
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              //this color must be equal to the WaterDropNavBar backgroundColor
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: Scaffold(
              body: _screens[_currentIndex],
              bottomNavigationBar: WaterDropNavBar(
                backgroundColor: colorWhite,
                waterDropColor: mainColor,
                selectedIndex: _currentIndex,
                onItemSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                barItems: [
                  BarItem(
                    outlinedIcon: Icons.home,
                    filledIcon:
                        _currentIndex == 0 ? Icons.home_rounded : Icons.home,
                  ),
                  BarItem(
                    outlinedIcon: Icons.message,
                    filledIcon:
                        _currentIndex == 1 ? Icons.chat_bubble : Icons.message,
                  ),
                  BarItem(
                    outlinedIcon: Icons.settings,
                    filledIcon: _currentIndex == 2
                        ? Icons.settings_input_component
                        : Icons.settings,
                  )
                ],
              ),
            )));
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop(); // For Android
              } else if (Platform.isIOS) {
                exit(0); // For iOS
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

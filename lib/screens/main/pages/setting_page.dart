import 'package:flutter/material.dart';
import 'package:muslim_mariage/screens/setting_pages/edit_profile.dart';
import 'package:muslim_mariage/screens/setting_pages/help.dart';
import 'package:muslim_mariage/screens/setting_pages/notification_screen.dart';
import 'package:muslim_mariage/screens/setting_pages/privacy_page.dart';
import 'package:muslim_mariage/screens/setting_pages/subscription_page.dart';
import 'package:muslim_mariage/widgets/logout_widget.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SectionHeader(title: "Account"),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => const EditProfile()));
            },
            child: const SettingsTile(
              icon: Icons.person,
              title: "Edit profile",
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => const NotificationScreen()));
            },
            child: const SettingsTile(
              icon: Icons.notifications,
              title: "Notifications",
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) =>
                          PrivacyPage(title: "Privacy Policy")));
            },
            child: const SettingsTile(
              icon: Icons.lock,
              title: "Privacy",
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: "Support & About"),
          GestureDetector(
            onTap: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (builder) => SubscriptionPage()));
            },
            child: const SettingsTile(
              icon: Icons.subscriptions,
              title: "My Subscription",
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => const Help()));
            },
            child: const SettingsTile(
              icon: Icons.help_outline,
              title: "Help & Support",
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) =>
                          PrivacyPage(title: "Terms and Policies")));
            },
            child: const SettingsTile(
              icon: Icons.info_outline,
              title: "Terms and Policies",
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: "Actions"),
          GestureDetector(
            onTap: () {
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return const LogoutWidget();
                },
              );
            },
            child: const SettingsTile(
              icon: Icons.logout,
              title: "Log out",
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const SettingsTile({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

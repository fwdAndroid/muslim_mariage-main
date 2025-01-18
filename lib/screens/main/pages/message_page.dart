import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_mariage/screens/tab/inbox.dart';
import 'package:muslim_mariage/screens/tab/recived_screen.dart';
import 'package:muslim_mariage/screens/tab/send_screen.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: <Widget>[
              ButtonsTabBar(
                labelSpacing: 60,
                radius: 100,
                contentCenter: true,
                width: 120,
                height: 50,
                backgroundColor: mainColor,
                unselectedLabelStyle: TextStyle(color: black),
                labelStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: GoogleFonts.inter().fontFamily),
                tabs: [
                  Tab(
                    text: "Send",
                  ),
                  Tab(
                    text: "Received",
                  ),
                  Tab(
                    text: "INBOX",
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    SendScreen(),
                    ReceivedScreen(),
                    InboxScreen()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PrivacyPage extends StatefulWidget {
  String title;
  PrivacyPage({super.key, required this.title});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''Lorem ipsum dolor sit amet, consectetur adipiscing elit...''', // Your legal terms
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            SizedBox(height: 16),
            // Show a message if terms are accepted or denied
          ],
        ),
      ),
    );
  }
}

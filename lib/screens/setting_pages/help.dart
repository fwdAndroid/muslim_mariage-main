import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/utils/showmesssage.dart';
import 'package:muslim_mariage/widgets/save_button.dart';
import 'package:uuid/uuid.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  final TextEditingController _messageController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double fontSize = screenWidth * 0.045;
    var uuid = Uuid().v4();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Help & Support'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No data available'));
            }
            var snap = snapshot.data;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report technical issues',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Type your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Spacer(),
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : SaveButton(
                          onTap: () async {
                            if (_messageController.text.isEmpty) {
                              showMessageBar(
                                  "Please Enter Your Message", context);
                              return;
                            } else {
                              setState(() {
                                isLoading = true;
                              });
                              await FirebaseFirestore.instance
                                  .collection("collectionPath")
                                  .doc(uuid)
                                  .set({
                                "message": _messageController.text,
                                "timestamp": DateTime.now(),
                                "uuid": uuid,
                                "email": snap['email'],
                                "name": snap['fullName'],
                              });
                              setState(() {
                                _messageController.clear();
                                isLoading = false;
                              });
                              showMessageBar(
                                  "Query Send To The Admin", context);
                            }
                          },
                          title: "Send",
                        ),
                ],
              ),
            );
          }),
    );
  }
}

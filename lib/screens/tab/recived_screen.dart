import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/screens/chat/message.dart';
import 'package:muslim_mariage/utils/colors.dart';

class ReceivedScreen extends StatefulWidget {
  const ReceivedScreen({super.key});

  @override
  State<ReceivedScreen> createState() => _ReceivedScreenState();
}

class _ReceivedScreenState extends State<ReceivedScreen> {
  void _acceptRequest(String docId, Map<String, dynamic> data) {
    FirebaseFirestore.instance
        .collection("chats")
        .doc(docId)
        .update({"isAccepted": true}).then((_) {
      // Show the confirmation dialog after accepting the request
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Request Accepted'),
            content: Text('You have accepted the following user request.'),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => Messages(
                        userId: data['userId'],
                        userName: data['userName'],
                        friendImage: data['friendImage'],
                        userPhoto: data['userPhoto'],
                        friendId: data['friendId'],
                        chatId: data['chatId'],
                        friendName: data['friendName'],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("chats")
                .where("friendId",
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .where("isAccepted", isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 120,
                      color: mainColor,
                    ),
                    Text('No Chat Request Found',
                        style: TextStyle(
                          color: mainColor,
                          fontSize: 20,
                        )),
                  ],
                ));
              }
              var userDocs = snapshot.data!.docs;

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: userDocs.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> data =
                      userDocs[index].data() as Map<String, dynamic>;
                  final docId = userDocs[index].id;

                  return Card(
                    child: ListTile(
                      onTap: () {},
                      trailing: TextButton(
                          onPressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirm'),
                                  content: Text(
                                      'Do you want to accept this request?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('No'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Yes'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _acceptRequest(docId, data);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            "Accept",
                            style: TextStyle(color: mainColor),
                          )),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(data['userPhoto']),
                      ),
                      title: Text(data['userName'] ?? 'No Name'),
                      subtitle: Text("Status: Pending"),
                    ),
                  );
                },
              );
            }));
  }
}

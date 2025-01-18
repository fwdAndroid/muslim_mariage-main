import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/utils/colors.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("chats")
                .where("userId",
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
                      Icons.send_sharp,
                      size: 120,
                      color: mainColor,
                    ),
                    Text('No Chat Request Send',
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

                itemCount: userDocs.length, // For simplicity
                itemBuilder: (context, index) {
                  final Map<String, dynamic> data =
                      userDocs[index].data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (builder) => ProfileDetail(
                        //         friendPhoto: data['image'] ??
                        //             Image.asset("assets/logo.png"),
                        //         friendName: data['fullName'],
                        //         friendId: data['uid'],
                        //         friendDOB: data['dob'] ?? "Not Available",
                        //         gender: data['gender'],
                        //         sect: data['sect'] ?? "Not Available",
                        //         cast: data['cast'] ?? "Not Available",
                        //         friendPhone: data['contactNumber'] ??
                        //             "Not Available",
                        //         friendQualification:
                        //             data['qualification'] ??
                        //                 "Not Available",
                        //         yourSelf: data['aboutYourself'] ??
                        //             "Not Available"),
                        //   ),
                        // );
                      },
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(data['friendImage']),
                      ),
                      title: Text(data['friendName'] ?? 'No Name'),
                      subtitle: Text("Status: Pending"),
                    ),
                  );
                },
              );
            }));
  }
}

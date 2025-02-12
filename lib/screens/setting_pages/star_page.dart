import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/utils/showmesssage.dart';

class StarPage extends StatefulWidget {
  const StarPage({
    Key? key,
  }) : super(key: key);

  @override
  _StarPageState createState() => _StarPageState();
}

class _StarPageState extends State<StarPage> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Star Profiles",
          ),
          centerTitle: true,
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where("star", arrayContains: currentUserId)
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
                      Icons.star,
                      color: Colors.grey,
                      size: 200,
                    ),
                    Text("No Star Profiles"),
                  ],
                ));
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var user = snapshot.data!.docs[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['image']),
                      ),
                      title: Text(user['fullName'] ?? "Unknown"),
                      subtitle: Text(user['contactNumber'] ?? "No Location"),
                      trailing: GestureDetector(
                        onTap: () async {
                          final docRef = FirebaseFirestore.instance
                              .collection("users")
                              .doc(user['uid']);
                          await docRef.update({
                            "star": FieldValue.arrayRemove([currentUserId])
                          });
                          showMessageBar("Removed From Star List", context);
                        },
                        child: Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ));
  }
}

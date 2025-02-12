import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/utils/showmesssage.dart';

class BlockedUsers extends StatefulWidget {
  const BlockedUsers({super.key});

  @override
  State<BlockedUsers> createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blocked Profiles"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUserId)
            .snapshots(),
        builder: (context, currentUserSnapshot) {
          if (currentUserSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!currentUserSnapshot.hasData ||
              !currentUserSnapshot.data!.exists) {
            return const Center(child: Text("User data not found"));
          }

          // Get the current user's blocked list
          List<dynamic> blockedIds = currentUserSnapshot.data!['blocked'] ?? [];

          if (blockedIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, size: 200, color: Colors.grey),
                  const Text("No Blocked Profiles"),
                ],
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where(FieldPath.documentId, whereIn: blockedIds)
                .snapshots(),
            builder: (context, blockedUsersSnapshot) {
              if (blockedUsersSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!blockedUsersSnapshot.hasData ||
                  blockedUsersSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No blocked users found"));
              }

              return ListView.builder(
                itemCount: blockedUsersSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var user = blockedUsersSnapshot.data!.docs[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['image']),
                      ),
                      title: Text(user['fullName'] ?? "Unknown"),
                      subtitle:
                          Text(user['contactNumber'] ?? "No contact info"),
                      trailing: IconButton(
                        icon: const Text("Unblock"),
                        onPressed: () async {
                          await _unblockUser(user.id);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _unblockUser(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .update({
        "blocked": FieldValue.arrayRemove([userId])
      });

      showMessageBar("User unblocked successfully", context);
    } catch (e) {
      showMessageBar("Error unblocking user: ${e.toString()}", context);
    }
  }
}

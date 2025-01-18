import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:muslim_mariage/screens/chat/message.dart';
import 'package:muslim_mariage/utils/colors.dart';

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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          "Messages",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .where("userId", isEqualTo: currentUserId)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> providerSnapshot) {
            final providerChats = providerSnapshot.data?.docs ?? [];

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chats")
                  .where("friendId", isEqualTo: currentUserId)
                  .snapshots(),
              builder:
                  (context, AsyncSnapshot<QuerySnapshot> customerSnapshot) {
                if (customerSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (customerSnapshot.hasError) {
                  return Center(
                    child: Text("Error: ${customerSnapshot.error}"),
                  );
                }

                final customerChats = customerSnapshot.data?.docs ?? [];
                final allChats = [...providerChats, ...customerChats];

                if (allChats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/nochat.png",
                          height: 300,
                          width: 200,
                        ),
                        Text(
                          "Aún no se han iniciado los chats.",
                          style: TextStyle(
                              color: black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: allChats.length,
                  itemBuilder: (context, index) {
                    final chatDoc = allChats[index];
                    final chatData = chatDoc.data() as Map<String, dynamic>;

                    // Determine other participant details
                    final bool isProvider = chatData['userId'] == currentUserId;
                    final String otherUserId =
                        isProvider ? chatData['friendId'] : chatData['userId'];
                    final String otherUserName = isProvider
                        ? chatData['friendName']
                        : chatData['userName'];
                    final String otherUserPhoto = isProvider
                        ? chatData['userPhoto']
                        : chatData['friendImage'];
                    final String lastMessage =
                        chatData['lastMessageByCustomer'] ??
                            chatData['lastMessageByProvider'] ??
                            "No Message";
                    final String timestampString = chatData['timestamp'] ?? "";
                    final DateTime? lastMessageTime = timestampString.isNotEmpty
                        ? DateTime.fromMillisecondsSinceEpoch(
                            int.parse(timestampString))
                        : null;

                    String formattedTime = "";
                    if (lastMessageTime != null) {
                      formattedTime = DateFormat.jm().format(lastMessageTime);
                    }

                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => Messages(
                                  userId: chatData['userId'],
                                  userName: chatData['userName'],
                                  friendImage: chatData['friendImage'],
                                  userPhoto: chatData['userPhoto'],
                                  friendId: chatData['friendId'],
                                  chatId: chatData['chatId'],
                                  friendName: chatData['friendName'],
                                ),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(otherUserPhoto),
                          ),
                          title: Text(
                            otherUserName,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          subtitle: Text(
                            lastMessage,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            formattedTime,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                                color: Colors.grey),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                );
              },
            );
          }),
    );
  }
}

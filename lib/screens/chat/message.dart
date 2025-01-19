import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_mariage/screens/chat/video_call_page.dart';
import 'package:muslim_mariage/screens/payment/payment_page.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:muslim_mariage/widgets/text_form_field.dart';

class Messages extends StatefulWidget {
  final String userId;
  final String friendId;
  final String userName;
  final String userPhoto;
  final String friendName;
  final String friendImage;
  final String chatId;

  const Messages({
    super.key,
    required this.chatId,
    required this.friendName,
    required this.friendImage,
    required this.userId,
    required this.userName,
    required this.friendId,
    required this.userPhoto,
  });

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late String groupChatId;
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  double uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    groupChatId = widget.friendId.hashCode <= widget.userId.hashCode
        ? "${widget.friendId}-${widget.userId}"
        : "${widget.userId}-${widget.friendId}";
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(widget.chatId)
          .child(fileName);

      final uploadTask = storageRef.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes!;
        });
      });

      try {
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        sendMessage(downloadUrl, 1); // Send the image message
      } catch (e) {
        print('Error uploading image: $e');
      }

      setState(() {
        uploadProgress = 0.0; // Reset progress after upload
      });
    }
  }

  void sendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      messageController.clear();

      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final String senderId = currentUserId;
      final String receiverId =
          (currentUserId == widget.friendId) ? widget.userId : widget.friendId;

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            "senderId": senderId,
            "receiverId": receiverId,
            "time": DateTime.now().millisecondsSinceEpoch.toString(),
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      }).then((value) {
        updateLastMessage(content, type);
      });

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      print("Message cannot be empty.");
    }
  }

  void updateLastMessage(String messageContent, int messageType) async {
    final chatDocRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Determine the fields to update for both participants
    final String fieldToUpdateForCurrentUser =
        (currentUserId == widget.friendId)
            ? 'lastMessageByCustomer'
            : 'lastMessageByProvider';
    final String fieldToUpdateForOtherUser = (currentUserId == widget.friendId)
        ? 'lastMessageByProvider'
        : 'lastMessageByCustomer';

    final chatDocSnapshot = await chatDocRef.get();
    if (chatDocSnapshot.exists) {
      String displayMessage = messageType == 1 ? 'Image sent' : messageContent;

      // Update both users' last messages
      await chatDocRef.update({
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        fieldToUpdateForCurrentUser: displayMessage,
        fieldToUpdateForOtherUser:
            displayMessage, // Update the other user as well
      }).catchError((error) {
        print("Failed to update last message: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => PaymentPage()));
              },
              icon: Icon(
                Icons.call,
                color: mainColor,
              ),
            ),
          )
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            const SizedBox(height: 3),
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                FirebaseAuth.instance.currentUser!.uid == widget.friendId
                    ? widget.userPhoto
                    : widget.friendImage,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              FirebaseAuth.instance.currentUser!.uid == widget.friendId
                  ? widget.userName
                  : widget.friendName,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("messages")
                .doc(groupChatId)
                .collection(groupChatId)
                .orderBy("timestamp", descending: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!.docs.isEmpty
                    ? const Expanded(
                        child: Center(child: Text("No messages yet.")),
                      )
                    : Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          reverse: false, // Reverse the order of messages
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var ds = snapshot.data!.docs[index];
                            final bool isCurrentUserSender =
                                ds.get("senderId") == currentUserId;
                            final bool isImageMessage = ds.get("type") == 1;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Align(
                                alignment: isCurrentUserSender
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: Column(
                                  crossAxisAlignment: isCurrentUserSender
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: isCurrentUserSender
                                            ? const Color(0xfff0f2f9)
                                            : const Color(0xff668681),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: isImageMessage
                                          ? Image.network(
                                              ds.get("content"),
                                              fit: BoxFit.cover,
                                              height: 160,
                                              width: 200,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child; // Image is fully loaded
                                                } else {
                                                  return Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        value: uploadProgress,
                                                        backgroundColor:
                                                            Colors.grey[300],
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                mainColor),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Text(
                                                        "${(uploadProgress * 100).toStringAsFixed(0)}% Uploading...",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Text(
                                                  'Failed to load image',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                );
                                              },
                                            )
                                          : Text(
                                              ds.get("content"),
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: isCurrentUserSender
                                                    ? black
                                                    : colorWhite,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat.jm().format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(ds.get("time")),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
              } else if (snapshot.hasError) {
                return const Center(child: Icon(Icons.error_outline));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
              height: 60,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormInputField(
                      controller: messageController,
                      hintText: "Send a message",
                      textInputType: TextInputType.name,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.photo, color: mainColor),
                    onPressed: pickAndUploadImage,
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    shape: const CircleBorder(),
                    onPressed: () {
                      sendMessage(messageController.text.trim(), 0);
                    },
                    backgroundColor: mainColor,
                    elevation: 0,
                    child:
                        const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
          if (uploadProgress > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: LinearProgressIndicator(
                value: uploadProgress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(mainColor),
              ),
            ),
        ],
      ),
    );
  }
}

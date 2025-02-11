import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_mariage/screens/chat/video_call_page.dart';
import 'package:muslim_mariage/screens/detail/chat_profile.dart';
import 'package:muslim_mariage/screens/payment/payment_page.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:muslim_mariage/widgets/text_form_field.dart';
// Add flutter_sound and permission_handler:
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // Audio recording and playback variables
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  bool isRecording = false;
  bool _isPlayerInited = false;
  String? _currentlyPlayingUrl;

  @override
  void initState() {
    super.initState();
    groupChatId = widget.friendId.hashCode <= widget.userId.hashCode
        ? "${widget.friendId}-${widget.userId}"
        : "${widget.userId}-${widget.friendId}";
    print(widget.friendName);
    initAudioRecorder();
    initAudioPlayer();
  }

  Future<void> initAudioRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
  }

  Future<void> initAudioPlayer() async {
    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer!.openPlayer();
    setState(() {
      _isPlayerInited = true;
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    _audioRecorder?.closeRecorder();
    _audioPlayer?.closePlayer();
    super.dispose();
  }

  Future<void> pickAndPreviewImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // Show a dialog for preview and approval
      bool? userApproved = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Preview Image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(file, fit: BoxFit.cover, height: 200),
              const SizedBox(height: 10),
              const Text("Do you want to send this image?")
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // User canceled
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true), // User approved
              child: const Text("Send"),
            ),
          ],
        ),
      );

      // If user approved, upload the image
      if (userApproved == true) {
        uploadImage(file);
      }
    }
  }

  Future<void> uploadImage(File file) async {
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
      sendMessage(downloadUrl, 1); // type 1 for image messages
    } catch (e) {
      print('Error uploading image: $e');
    }

    setState(() {
      uploadProgress = 0.0; // Reset progress
    });
  }

  // AUDIO RECORDING METHODS

  Future<void> startRecording() async {
    try {
      await _audioRecorder!.startRecorder(
        toFile: 'audio_message.aac',
      );
      setState(() {
        isRecording = true;
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await _audioRecorder!.stopRecorder();
      setState(() {
        isRecording = false;
      });
      if (path != null) {
        uploadAudio(File(path));
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> uploadAudio(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('chat_audio')
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
      sendMessage(downloadUrl, 2); // type 2 for audio messages
    } catch (e) {
      print('Error uploading audio: $e');
    }

    setState(() {
      uploadProgress = 0.0;
    });
  }

  // SEND MESSAGE METHOD (includes a "status" field)
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
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "content": content,
            "type": type,
            "status": "sent", // Default status when sent
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

    final String fieldToUpdateForCurrentUser =
        (currentUserId == widget.friendId)
            ? 'lastMessageByCustomer'
            : 'lastMessageByProvider';
    final String fieldToUpdateForOtherUser = (currentUserId == widget.friendId)
        ? 'lastMessageByProvider'
        : 'lastMessageByCustomer';

    final chatDocSnapshot = await chatDocRef.get();
    if (chatDocSnapshot.exists) {
      String displayMessage = messageType == 1
          ? 'Image sent'
          : (messageType == 2 ? 'Audio sent' : messageContent);

      await chatDocRef.update({
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        fieldToUpdateForCurrentUser: displayMessage,
        fieldToUpdateForOtherUser: displayMessage,
      }).catchError((error) {
        print("Failed to update last message: $error");
      });
    }
  }

  // Build a widget for audio messages (with play/pause)
  Widget _buildAudioMessage(String audioUrl, bool isCurrentUser) {
    final playerController = PlayerController();

    // Initialize the waveform player properly
    playerController.extractWaveformData(
      path: audioUrl,
    );

    bool isPlaying =
        (_currentlyPlayingUrl == audioUrl && _audioPlayer!.isPlaying);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: isCurrentUser ? Colors.black : mainColor,
            ),
            onPressed: () async {
              if (isPlaying) {
                await _audioPlayer!.stopPlayer();
                _currentlyPlayingUrl = null;
              } else {
                if (_currentlyPlayingUrl != null && _audioPlayer!.isPlaying) {
                  await _audioPlayer!.stopPlayer();
                }
                _currentlyPlayingUrl = audioUrl;
                await _audioPlayer!.startPlayer(
                  fromURI: audioUrl,
                  whenFinished: () {
                    _currentlyPlayingUrl = null;
                  },
                );
              }
            },
          ),
          Image.asset("assets/wave.png", height: 80, width: 100)
        ],
      ),
    );
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => VideoCall(
                              friendName: widget.friendName,
                              callingid: widget.userId,
                            )));
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
        title: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => ChatProfile(
                          friendId: widget.friendId,
                        )));
          },
          child: Column(
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
                if (snapshot.data!.docs.isEmpty) {
                  return const Expanded(
                    child: Center(child: Text("No messages yet.")),
                  );
                } else {
                  return Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      controller: scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var ds = snapshot.data!.docs[index];
                        final int messageType = ds.get("type");
                        final bool isCurrentUserSender =
                            ds.get("senderId") == currentUserId;

                        // If this is a received message and it is not yet marked "seen," update it.
                        if (!isCurrentUserSender &&
                            ds.get("status") != 'seen') {
                          Future.microtask(() {
                            FirebaseFirestore.instance
                                .collection('messages')
                                .doc(groupChatId)
                                .collection(groupChatId)
                                .doc(ds.id)
                                .update({'status': 'seen'});
                          });
                        }

                        Widget messageContentWidget;
                        if (messageType == 1) {
                          // Image message
                          messageContentWidget = Image.network(
                            ds.get("content"),
                            fit: BoxFit.cover,
                            height: 160,
                            width: 200,
                          );
                        } else if (messageType == 2) {
                          // Audio message
                          messageContentWidget = _buildAudioMessage(
                              ds.get("content"), isCurrentUserSender);
                        } else {
                          // Text message
                          messageContentWidget = Text(
                            ds.get("content"),
                            style: TextStyle(
                              fontSize: 15,
                              color: isCurrentUserSender ? black : colorWhite,
                            ),
                          );
                        }

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
                                  child: messageContentWidget,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
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
                                    if (isCurrentUserSender)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Icon(
                                          ds.get("status") == 'seen'
                                              ? Icons.done_all
                                              : Icons.done,
                                          color: ds.get("status") == 'seen'
                                              ? Colors.blue
                                              : Colors.grey,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              } else if (snapshot.hasError) {
                return const Expanded(
                  child: Center(child: Icon(Icons.error_outline)),
                );
              } else {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
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
                  IconButton(
                    icon: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      color: mainColor,
                    ),
                    onPressed: () {
                      if (isRecording) {
                        stopRecording();
                      } else {
                        startRecording();
                      }
                    },
                  ),
                  Expanded(
                    child: TextFormInputField(
                      controller: messageController,
                      hintText: "Send  message",
                      textInputType: TextInputType.name,
                    ),
                  ),

                  // Audio recording button: tap to start (mic icon) or stop (stop icon)

                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.photo, color: mainColor),
                    onPressed: pickAndPreviewImage,
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: mainColor),
                    onPressed: () {
                      sendMessage(messageController.text.trim(), 0);
                    },
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

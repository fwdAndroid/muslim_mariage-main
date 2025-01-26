import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'dart:math' as math;

class VideoCall extends StatefulWidget {
  String friendName;
  String callingid;
  VideoCall({super.key, required this.friendName, required this.callingid});

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final String localUserID = math.Random().nextInt(10000).toString();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ZegoUIKitPrebuiltCall(
            callID: widget.callingid,
            appID: 1277715557,
            appSign:
                "34ca449bbd5a017fd33a22652c780c7dc1e0c14caacacf06218fdf7ade919da5",
            userID: localUserID,
            userName: widget.friendName + '$localUserID',
            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              ..layout = ZegoLayout.pictureInPicture(
                isSmallViewDraggable: true,
                switchLargeOrSmallViewByClick: true,
              )));
  }
}

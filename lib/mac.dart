import 'package:flutter/material.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';

// 不能用 video_player

class Mac extends StatefulWidget {
  Mac({Key? key}) : super(key: key);

  @override
  _MacState createState() => _MacState();
}

class _MacState extends State<Mac> {
  VideoPlayerController? _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

  }

  @override
  void reassemble() async {
    super.reassemble();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        // padding: EdgeInsets.only(top: 24.0),
        child:  Scaffold(
          appBar: AppBar(
            // leading: IconButton(
            //   icon: Icon(
            //     Icons.arrow_back_ios_sharp,
            //     color: Colors.white,
            //   ),
            //   onPressed: () => Navigator.pop(context),
            // ),
            title: Text('MyTube'),
            actions: [
              IconButton( // 另存新檔
                icon: Icon(
                  Icons.file_copy,
                  color: Colors.white,
                ),
                onPressed: () {
                  // fileSave(context, this.widget.url); 
                }
              ),
            ],
          ),
          body: _controller!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              : Container(),
        )
      )
    );
  }

  Future<bool> _onWillPop() async {
      // return Future.value(false); // 表示不退出
      return Future.value(true);
  }

}

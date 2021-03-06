import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';
//https://pub.dev/packages/youtube_explode_dart

enum Mode {
   none,
   video,
   audio,
}  

class Download {
  String title = "", author = "", fileName = "", path = "", url = "", mb = "";
  int qualityHigh = -1, qualityLow = -1, qualityMedium = -1, selected = -1, position = 0;
  Duration duration = Duration(seconds: 0);
  
  final yt = YoutubeExplode();
  bool stop = false;
  Mode mode = Mode.none;
  var audio, streams;

  // String get key {
  //   return url.replaceAll("https://m.youtube.com/watch?v=", "");
  // }

  static Future<String> folder() async {
    final methodChannel = const MethodChannel('com.flutter/MethodChannel');
    String directory = await methodChannel.invokeMethod('getDownloadsDirectory');
    return directory;
  }

  static parselKey(String key){
    return key.replaceAll("https://m.youtube.com/watch?v=", "");
  }


  Future<void> initial(String url) async {
    this.url = url;
    try {
      var video = await yt.videos.get(url);
      title = video.title;
      author = video.author;
      duration = video.duration ?? Duration(seconds: 0); // Instance of Duration - 0:19:48.00000
      // print("${video}");
    } catch(e){
      print(e);
      throw e;
    }
  }

  Future<dynamic> getVideoStream() async {
    try {
      mode = Mode.video; mb = ""; qualityHigh = -1; qualityLow = -1; qualityMedium = -1; selected = -1;
      var manifest = await yt.videos.streamsClient.getManifest(url);
      streams = manifest.muxed; // manifest.videoOnly;
      return streams;
    } catch(e) {
      print(e);
      throw e;
    }
  }

  Future<void> getAudioStream() async {
    try {
      mode = Mode.audio;  mb = ""; qualityHigh = -1; qualityLow = -1; qualityMedium = -1; selected = -1;
      var manifest = await yt.videos.streamsClient.getManifest(url);
      streams = manifest.audioOnly;
    } catch(e) {
      print(e);
      throw e;
    }
  }

  dispose(){
    yt.close();
  }

  Future<void> execute({String fileName = "", String folder = "", required Function(int) onProcessing}) async {
    stop = false;
    try {
      mb = "${audio.size.totalMegaBytes.toStringAsFixed(2) + 'MB'}";
      fileName = ((fileName.length == 0) ? 'youtube' : fileName);
      if(fileName.indexOf(".") == -1)
        fileName += '.${audio.container.name.toString()}';

      path = await Download.folder();
      // print("MyTube: $path");
      if(Directory(path).existsSync() == false)
        Directory(path).createSync();

      if(folder.length > 0 && Directory(path + '/$folder').existsSync() == false) {
          Directory(path + '/$folder').createSync();
      }
      
      this.fileName = path + (folder.length > 0 ? '/$folder' : '') + '/$fileName';
      var file = File(this.fileName);
      removeFile();

      var audioStream = yt.videos.streamsClient.get(audio); 
      var output = file.openWrite(mode: FileMode.writeOnlyAppend);
      var len = audio.size.totalBytes;
      var count = 0;

      await for (final data in audioStream) {
        count += data.length;
        var progress = ((count / len) * 100).ceil();
        if(stop == false) {
          onProcessing(progress);
        } else {
          
          break;
        }
        output.add(data);
      }
      if(stop == true)
        removeFile();
      else 
        await output.close();
    } catch(e) {
      print(e);
      throw e;
    }
  }
  removeFile(){
    var file = File(this.fileName);
    if(fileName.indexOf("youtube.") > -1) {
      List f1 = ['3gpp', 'webm', 'mp4'];
      for(var i = 0; i < f1.length; i++) {
        String fn = path + '/' + 'youtube.' + f1[i]; // /$folder
        var f2 = File(fn);
        if (f2.existsSync()) {
          f2.deleteSync();
        }
      }
    } else if (file.existsSync()) {
      file.deleteSync();
    }
  }
}
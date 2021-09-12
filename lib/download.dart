import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
//https://pub.dev/packages/youtube_explode_dart

class Download {
  String title = "", author = "", fileName = "", path = "", url = "";
  Duration duration = Duration(seconds: 0);
  final yt = YoutubeExplode();
  bool stop = false;
  var audio;

  static Future<String> folder() async {
    final methodChannel = const MethodChannel('com.flutter/MethodChannel');
    String directory = await methodChannel.invokeMethod('getDownloadsDirectory');
    return directory + '/MyTube';
  }

  Future<void> getVideo(String url) async {
    this.url = url;
    try {
      // final methodChannel = const MethodChannel('com.flutter/MethodChannel');
      // String directory = await methodChannel.invokeMethod('getDownloadsDirectory');
      // path = directory + '/MyTube';
      path = await Download.folder();
      // print("MyTube: $path");
      if(Directory(path).existsSync() == false)
        Directory(path).createSync();

      var video = await yt.videos.get(url);
      title = video.title;
      author = video.author;
      duration = video.duration ?? Duration(seconds: 0); // Instance of Duration - 0:19:48.00000

      print("${video}");
    } catch(e){
      print(e);
      throw e;
    }
  }

  Future<void> getVideoStream() async {
    try {
      var manifest = await yt.videos.streamsClient.getManifest(url);
      var streams = manifest.muxed; // manifest.videoOnly;
      var audio1 = streams.withHighestBitrate();
      var audio2 = streams.first;
      var audio3 = streams.last;

      // var streams.videoOnly.where((e) => e.container == Container)
      // audio2.videoQuality == VideoQuality.
      print("MyTube.audio1.size: ${audio1.size}, videoQuality: ${audio1.videoQuality}, videoCodec: ${audio1.videoCodec}, audioCodec: ${audio1.audioCodec}");
      print("MyTube.audio2.size: ${audio2.size}, videoQuality: ${audio2.videoQuality}, videoCodec: ${audio2.videoCodec}, audioCodec: ${audio2.audioCodec}");
      print("MyTube.audio3.size: ${audio3.size}, videoQuality: ${audio3.videoQuality}, videoCodec: ${audio3.videoCodec}, audioCodec: ${audio3.audioCodec}");

      if(audio2.videoQuality.toString().indexOf(".medium") > -1)
        audio = audio2;
      else if(audio3.videoQuality.toString().indexOf(".medium") > -1)
        audio = audio3;
      else
        audio = audio2.size.totalBytes > audio3.size.totalBytes ? audio2 : audio3;
      print("MyTube.audio.size: ${audio.size}, videoQuality: ${audio.videoQuality}, videoCodec: ${audio.videoCodec}, audioCodec: ${audio.audioCodec}");
      /*
      var manifest = await yt.videos.streamsClient.getManifest(id);
      var streams = manifest.videoOnly;

      // Get the audio track with the highest bitrate.
      var audio = streams.first;
      var audioStream = yt.videos.streamsClient.get(audio);
      */
    } catch(e) {
      print(e);
      throw e;
    }
  }

  Future<void> getAudioStream() async { // ok 的
    try {
      var manifest = await yt.videos.streamsClient.getManifest(url);
      var streams = manifest.audioOnly;
      audio = streams.last;
    } catch(e) {
      print(e);
      throw e;
    }
  }

  Future<void> execute({String fileName = "", String folder = "", bool isVideo = true, required Function(int) onProcessing}) async {
    try {
      if(isVideo == true)
        await getVideoStream();
      else 
        await getAudioStream();

      fileName = ((fileName.length == 0) ? 'youtube' : fileName) 
        + '.${audio.container.name.toString()}';

      if(folder.length > 0 && Directory(path + '/$folder').existsSync() == false) {
          Directory(path + '/$folder').createSync();
      }
      
      this.fileName = path + (folder.length > 0 ? '/$folder' : '') + '/$fileName';
      var file = File(this.fileName);

      if (file.existsSync()) {
        file.deleteSync();
      }

      var audioStream = yt.videos.streamsClient.get(audio); // 有聲音，但有 2倍長度
      var output = file.openWrite(mode: FileMode.writeOnlyAppend);
      var len = audio.size.totalBytes;
      var count = 0;

      await for (final data in audioStream) {
        count += data.length;
        var progress = ((count / len) * 100).ceil();
        if(stop == false) onProcessing(progress);
        output.add(data);
      }
      await output.close();
      yt.close();
    } catch(e) {
      print(e);
      throw e;
    }
  }
}
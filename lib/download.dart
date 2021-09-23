import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
//https://pub.dev/packages/youtube_explode_dart

class Download {
  String title = "", author = "", fileName = "", path = "", url = "", mb = "";
  int qualityHigh = -1, qualityLow = -1, qualityMedium = -1;
  Duration duration = Duration(seconds: 0);
  final yt = YoutubeExplode();
  bool stop = false, isVideo = false;
  var audio = null, streams;

  static Future<String> folder() async {
    final methodChannel = const MethodChannel('com.flutter/MethodChannel');
    String directory = await methodChannel.invokeMethod('getDownloadsDirectory');
    return directory + '/MyTube';
  }

  Future<void> getVideo(String url) async {
    this.url = url;
    try {
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

  Future<dynamic> getVideoStream() async {
    try {
      isVideo = true; mb = ""; qualityHigh = -1; qualityLow = -1; qualityMedium = -1;
      print("MyTube.url: $url");
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
      isVideo = false;  mb = ""; qualityHigh = -1; qualityLow = -1; qualityMedium = -1;
      var manifest = await yt.videos.streamsClient.getManifest(url);
      streams = manifest.audioOnly;
      // audio = streams.last;
    } catch(e) {
      print(e);
      throw e;
    }
  }

  Widget gridView(BuildContext context, {Function(int)? onPress, Function()? onReady}){
    List arr = this.streams.toList();
    if(isVideo == true && arr.length > 7) {
      for(int i = arr.length -1; i >= 0; i--){
        String quality =  "${arr[i].videoQuality}".replaceAll("VideoQuality.", "");
       
        print("quality: $quality");
        if(quality.indexOf("high") > -1)
          break;
        else
          arr.removeLast();
      }
    }

    for(int i = 0; i < arr.length; i++){
      String quality = isVideo == true ? "${arr[i].videoQuality}".replaceAll("VideoQuality.", "") : "";
      if(quality.indexOf("medium") == 0 && qualityMedium == -1){
        qualityMedium = i;
      } else if(quality.indexOf("high") == 0 && qualityHigh == -1) {
        qualityHigh = i;
      }  
    }


    double width = MediaQuery.of(context).size.width;
    int w = width < 800 ? 150 : 180;
    int cells = (width / w).ceil();
    return Container(//容器内补白
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.lightBlue)
      ),
      margin: EdgeInsets.only(top: 10.0, bottom: 10.0), 
      // padding: EdgeInsets.all(0.0),
      child:  GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cells, //每行三列
            childAspectRatio: 1.2, //显示区域宽高相等
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
        ),
        itemCount: arr.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          String mb = "${arr[index].size.totalMegaBytes.toStringAsFixed(1) + 'MB'}",
            quality = isVideo == true ? "${arr[index].videoQuality}".replaceAll("VideoQuality.", "") : "";
          Color bg = Colors.grey.shade200, color = Colors.black;
          if(isVideo == true){
            if(quality.indexOf("medium") == 0){
              bg = Colors.green.shade500;
              color = Colors.white;
            } else if(quality.indexOf("high") == 0) {
              bg = Colors.red.shade500; 
              color = Colors.white;
            }  
          }

          double fontSize = width < 800 ? 16 : 24;
          if(index == arr.length -1) { // 在第一次自動觸發
            onReady!();
          }
          return Material(
            child: InkWell(
              onTap: () async {
                if(onPress is Function)
                  onPress!(index);
                onPress = null;
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: bg
                ),
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text( mb,
                      style: TextStyle(
                        color: color,
                        fontSize: fontSize,
                      ),
                    ),
                    if(quality.length > 0)
                      Container(height: 5),
                    if(quality.length > 0)
                      Text( quality,
                        style: TextStyle(
                          color: color,
                          fontSize: fontSize,
                        ),
                      ),
                    Container(height: 5,),
                    Text("${arr[index].container.name.toString()}",
                      style: TextStyle(
                        color: color,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                )
            )
          )
        ); 
        }
      )
    );
  }

  dispose(){
    yt.close();
  }

  Future<void> execute({String fileName = "", String folder = "", required Function(int) onProcessing}) async {
    try {
      print("MyTube.audio: ${audio.size.totalMegaBytes.toStringAsFixed(2) + 'MB'}, videoQualityLabel: ${audio.videoQualityLabel}, videoQuality: ${audio.videoQuality}, videoCodec: ${audio.videoCodec}, audioCodec: ${audio.audioCodec}");
      // print("MyTube.container: " + audio.container.name.toString());
      mb = "${audio.size.totalMegaBytes.toStringAsFixed(2) + 'MB'}";

      fileName = ((fileName.length == 0) ? 'youtube' : fileName) 
        + '.${audio.container.name.toString()}';

      path = await Download.folder();
      // print("MyTube: $path");
      if(Directory(path).existsSync() == false)
        Directory(path).createSync();

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
    } catch(e) {
      print(e);
      throw e;
    }
  }
}
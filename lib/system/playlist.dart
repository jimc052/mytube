import 'package:mytube/download.dart';
import 'dart:io';
import 'dart:convert';

class Playlist {
  Map<String, dynamic> _data = {};
  Playlist? _playlist;
  String path = "";

  Future<Map<String, dynamic>> initial() async {
    path = await Download.folder() + "/playlist.txt";
    var filePlayList = File(path);
    if(filePlayList.existsSync() == true){
      final content = filePlayList.readAsStringSync();
      _data = jsonDecode(content);
      var arr = [];
      _data.forEach((k, v) {
        if(v.length == 0) {
          arr.add(k);
        }
      });
      arr.forEach((el) {
        _data.remove(el);
      });
    }
    return _data;
  }

  get data{
    return _data;
  }
  set data(value) {
    _data = value;
  }

  add(String key, Map<String, dynamic> value){
    if(! _data.containsKey(key)) {
      _data[key] = [];
    }
     _data[key].add(value);
    save();
  }

  save(){
    var filePlayList = File(path);
    filePlayList.writeAsStringSync(jsonEncode(_data));
  }
}
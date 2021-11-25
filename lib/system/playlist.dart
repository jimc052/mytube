import 'package:mytube/download.dart';
import 'dart:io';
import 'dart:convert';

class Playlist {
  Map<String, dynamic> _data = {};
  Playlist? _playlist;
  String path = "";

  Future<Map<String, dynamic>> initial() async {
    path = await Download.folder() + "/playlist.json";
    var filePlayList = File(path);
    if(filePlayList.existsSync() == true){
      final content = filePlayList.readAsStringSync();
      // print("MyTube.playlist: ${content}");
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
    print("MyTube.value: ${value["key"]}");
    if(! _data.containsKey(key)) {
      _data[key] = [];
    } else {
      for(int i = 0; i < _data[key].length; i++) {
        print("MyTube. $i: ${_data[key][i]["key"]}");
        if(value["key"] == _data[key][i]["key"]) {
          _data[key][i]["fileName"] = value["fileName"];
          _data[key][i]["date"] = value["date"];
          save();
          return;
        }
      }
    }
     _data[key].add(value);
    save();
  }

  update(String key, Map<String, dynamic> value){
    if(_data.containsKey(key)) {
      for(int i = 0; i < _data[key].length; i++) {
        if(value["key"] == _data[key][i]["key"]) {
          _data[key][i] = value;
          save();
          return;
        }
      }
    }
  }

  Map<String, dynamic>? search(String key){
    String folder = "";
    Map<String, dynamic>? _item;
    _data.forEach((k, v) {
      if(_item != null) return;
      for(int i = 0; i < v.length; i++) {
        if(v[i]["key"] == key) {
          folder = k;
          _item = v[i];
          return;
        }
      }
    });
    return folder.length == 0 ? null : {"key": folder, "item": _item};
  }

  save(){
    var filePlayList = File(path);
    filePlayList.writeAsStringSync(jsonEncode(_data));
  }
}
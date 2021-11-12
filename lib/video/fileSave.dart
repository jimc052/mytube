import 'package:flutter/material.dart';
import 'package:mytube/download.dart';
import 'dart:io';
import 'package:mytube/system/system.dart';
import 'dart:convert';
import 'package:mytube/extension/extension.dart';
import 'package:mytube/system/playlist.dart';

class FileSave extends StatefulWidget {
  String videoKey, fileName, title, author;
  FileSave({Key? key, required this.videoKey, this.fileName = "", required this.title, required this.author}) : super(key: key);

  @override
  _FileSaveState createState() => _FileSaveState();
}

class _FileSaveState extends State<FileSave> {
  String path = "", activeFolder= "", activeFileName = "";
  final TextEditingController textEditingControllerF = new TextEditingController();
  final TextEditingController textEditingControllerD = new TextEditingController();
  final scrollController = ScrollController();
  bool saved = false, exists = false;
  var dialogContext;
  var background = Color.fromRGBO(38, 38, 38, 0.8);
  Playlist playlist = Playlist();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if(path.length == 0){
      path = await Download.folder();
      await playlist.initial();
     
      playlist.data.forEach((k, v) {
        // print("MyTube.playlist: ${k}");
        if(exists == false) {
          for(var i = 0; i < v.length; i++) {
            if(v[i]["key"] == this.widget.videoKey){
              activeFolder = k;
              activeFileName = v[i]["fileName"];
              exists = true;
              break;
            }
          }
        }
      });
      if(exists == false) {
        textEditingControllerF.text = trimChar(this.widget.title);
        textEditingControllerD.text = trimChar(this.widget.author);
      }
      setState(() {}); 
    }
  }

  String trimChar(String s) {
    s = s.replaceAll(r'\', '')
      .replaceAll('/', '')
      .replaceAll('*', '')
      .replaceAll('?', '')
      .replaceAll('"', '')
      .replaceAll('<', '')
      .replaceAll('>', '')
      .replaceAll('|', '');

    if(s.length > 30)
      s = s.substring(0, 30);
    return s;
  }
  
  @override
  dispose() {
    textEditingControllerF.dispose();
    textEditingControllerD.dispose();
    super.dispose();
  }
  @override
  void reassemble() async {
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black54,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
              color: Colors.orange,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('另存新檔',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 20,
            )
          ),
        ),
        body: body(),
        floatingActionButton: saved == false && exists == false
          ? FloatingActionButton(
              backgroundColor: Colors.black87,
              onPressed: () async {
                save();
              },
              child:  Icon(Icons.save_sharp, size: 30, color: Colors.orange)
          )
          : Container() 
      )
    );
  }

  void save(){
    if(textEditingControllerF.text.length == 0) {
      alert(context, "請輸入檔案名稱");
    } else if(textEditingControllerD.text.length == 0) {
      alert(context, "請輸入目錄名稱");
    } else {
      String path2 = path + "/" + textEditingControllerD.text;
      if(Directory(path2).existsSync() == false)
        Directory(path2).createSync();

      var file = File(this.widget.fileName);
      String ext = this.widget.fileName.substring(this.widget.fileName.indexOf(".", this.widget.fileName.length - 7));
      String f2 = path2 + "/" + textEditingControllerF.text + ext;
      var file2 = File(f2);
      if(file2.existsSync() == false){
        file.copySync(f2);
        saved = true;
        setState(() {});
        final DateTime now = DateTime.now();
        var list = {
          "key": this.widget.videoKey, 
          "title": this.widget.title, 
          "author": this.widget.author, 
          "date": now.formate(), 
          "fileName": textEditingControllerF.text + ext
        };
        playlist.add(textEditingControllerD.text, list);
        
        // alert(context, "存檔完成!!");
        Navigator.pop(context, {"folder": textEditingControllerD.text, "playItem": list});
      } else {
        alert(context, "檔案已存在!!");
      }
    }
  }

  Widget body(){
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: background,
      ),
      child: Column(
        children:  [
          if(saved == false && exists == false)
            Row(children: [
              Flexible(child: TextField(
                  style: TextStyle(color: Colors.orange),
                  controller: textEditingControllerF,
                  onChanged: (text) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: '檔案名稱',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(width: 1, color: Colors.green)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(width: 1, color: Colors.orange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(width: 1,color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ),
              // Container(width: 5),
              myButton(Icons.undo, 
                onPress:(){
                  textEditingControllerF.text = trimChar(this.widget.title);
                  setState(() {});
                }, 
                disable: textEditingControllerF.text == trimChar(this.widget.title)
              )
            ]),
          if(saved == false && exists == false) 
            Container(height: 5),
          if(saved == false && exists == false)
            Row(children: [
              Flexible(child: TextField(
                  style: TextStyle(color: Colors.orange),
                  controller: textEditingControllerD,
                  onChanged: (text) {
                    setState(() {});
                  },
                  decoration: new InputDecoration(
                    hintText: '目錄名稱',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(width: 1, color: Colors.green)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(width: 1, color: Colors.orange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(width: 1, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ),
              // Container(width: 5),
              myButton(Icons.undo, 
                onPress: (){
                  textEditingControllerD.text = trimChar(this.widget.author);
                  setState(() {});
                }, 
                disable: textEditingControllerD.text == trimChar(this.widget.author)
              )
            ]),
          if(path.length > 0)
            Expanded( flex: 1, 
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Container(margin: EdgeInsets.only(top: 15.0), child: fileList(path)),
                )
              )
            ),
        ]
      )
    );
  }

  List readFiles(folder){
    List files = [];
    if(Directory(folder).existsSync()){
      List f1 = Directory(folder).listSync();
      List f2 = [], d = []; 
      for(int i = 0; i < f1.length; i++) {
        if(f1[i] is File) {
          var s = (f1[i] as File).path;
          if(s.indexOf("/youtube.") > -1 || s.indexOf(".txt") > -1 || s.indexOf(".json") > -1) {
            continue;
          } else 
            f2.add(f1[i]);
        } else 
          d.add(f1[i]);
      }

      for(int i = 0; i < d.length; i++) {
        files.add(d[i]);
      }
      for(int i = 0; i < f2.length; i++) {
        files.add(f2[i]);
      }
    } else 
      Directory(folder).createSync();
    return files;
  }
  
  Widget fileList(folder){
    List files =  readFiles(folder);
    return(
      Column(children: [
        for(var item in files)
          item is File
              ? widgetFile((item as File).path)
              : widgetDirectory((item as Directory).path)
      ])
    );
  }
  
  Widget widgetFile(String name){
    var arr = name.split("/");
    bool e = activeFileName == arr[arr.length - 1];
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file,
            color: e == true ? Colors.orange[200] : Colors.grey[400],
            size: 20,
          ),
          Padding(padding: EdgeInsets.only(right: 5)),
          Flexible(child: Container(
              padding: new EdgeInsets.only(right: 13.0),
              child: Text(arr[arr.length - 1],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: e == true ? Colors.orange[200] : Colors.grey[400],
                  fontSize: 20,
                ),
              )
            )
          )
        ],
      )
    );
  }
  
  Widget widgetDirectory(String name){
    bool same = name.replaceAll(path + "/", "") == activeFolder.replaceAll(path + "/", "");
    return Column(children: [
      Material(
      color: Colors.transparent,
      child:  InkWell(
        onTap: (){
          if(activeFolder != name){
            activeFolder = name;
            textEditingControllerD.text = name.replaceAll(path + "/", "");
          } else 
            activeFolder = "";
          setState(() { });
        },
        // splashColor: Colors.red,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(same == true ? Icons.folder_open : Icons.folder,
                color: same == true ? Colors.orange : Colors.grey.shade400,
                size: 20
              ),
              Padding(padding: EdgeInsets.only(right: 5)),
              Text(name.replaceAll(path + "/", ""),
                style: TextStyle(
                  color: same == true ? Colors.orange : Colors.grey.shade400,
                  fontSize: 20,
                ),
              )
            ],
          )
        )
      )
    ),
    if(same == true)
        Container(
          child: fileList(name),
          margin: EdgeInsets.only(left: 15.0),
          // padding: EdgeInsets.all(3.0),
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.blueAccent)
          // ),
          // height: 30
        )
    ]);
  }

  Widget myButton(IconData icon, {required Function() onPress, bool disable = false}){
    return Material(
      color: Colors.transparent,
      child: Ink(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          padding: const EdgeInsets.all(0.0),
          // margin: const EdgeInsets.only(left: 5.0),
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(5),
            // border: Border.all(color: disable == false ? Colors.orange : Colors.grey.shade600, width: 1),
            // color: background,
          ),
          child: IconButton(
            padding: const EdgeInsets.all(0.0),
            icon: Icon(icon),
            color: disable == false ?  Colors.orange : Colors.grey.shade600,
            iconSize: 25,
            onPressed: () {
              if(disable == false)
                onPress();
            },
          )
        ),
      )
    );
  }
}
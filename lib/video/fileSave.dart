import 'package:flutter/material.dart';
import 'package:mytube/download.dart';
import 'dart:io';
import 'package:mytube/system/system.dart';

void fileSave(BuildContext context, {String url = "", isLocal = false}) {
  showDialog(
    barrierDismissible: false,
    context: context, 
    builder: (BuildContext context) => Panel(url: url, isLocal: isLocal),
  );
}

class Panel extends StatefulWidget {
  String url;
  bool isLocal = false;
  Panel({Key? key, this.url = "", isLocal = false}) : super(key: key);

  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  
  String path = "", title = "", _folder = "", fileName = "", activeFolder= "";
  final TextEditingController textEditingControllerF = new TextEditingController();
  final TextEditingController textEditingControllerD = new TextEditingController();
  final scrollController = ScrollController();
  bool saved = false;
  var dialogContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if(path.length == 0){
      path = await Download.folder();
      fileName = await Storage.getString("fileName");
       /*
        download.title = await Storage.getString("title");
        download.author = await Storage.getString("author");
        download.mb = await Storage.getString("mb");
        download.duration = Duration(milliseconds: await Storage.getInt("duration"));
      */

      textEditingControllerF.text = title = trimChar(await Storage.getString("title"));
      textEditingControllerD.text = _folder = trimChar(await Storage.getString("author"));
      setState(() {
      });
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('另存新檔'),
      ),
      body: body(),
      floatingActionButton: saved == false
        ? FloatingActionButton(
            onPressed: () async {
              save();
            },
            child:  Icon(Icons.save_sharp, size: 30, color: Colors.white)
        )
        : Container() 
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

      var file = File(fileName);
      String ext = fileName.substring(fileName.indexOf(".", fileName.length - 7));
      String f2 = path2 + "/" + textEditingControllerF.text + ext;
      var file2 = File(f2);
      if(file2.existsSync() == false){
        file.copySync(path2 + "/" + textEditingControllerF.text + ext);
        alert(context, "存檔完成!!");
        saved = true;
        setState(() {});
      } else {
        alert(context, "檔案已存在!!");
      }
    }
  }

  Widget body(){
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children:  [
          if(saved == false)
            Row(children: [
              Flexible( child: TextField(
                  controller: textEditingControllerF,
                  onChanged: (text) {
                    setState(() {});
                  },
                  decoration: new InputDecoration(
                    hintText: '檔案名稱',
                  ),
                ),
              ),
              Container(width: 15),
              myButton(Icons.undo, 
                onPress:(){
                  textEditingControllerF.text = title;
                  setState(() {});
                }, 
                disable: textEditingControllerF.text == title
              )
            ]),
          if(saved == false) 
            Container(height: 5),
          if(saved == false)
            Row(children: [
              Flexible(child: TextField(
                  controller: textEditingControllerD,
                  onChanged: (text) {
                    setState(() {});
                  },
                  decoration: new InputDecoration(
                    hintText: '目錄名稱',
                  ),
                ),
              ),
              Container(width: 15),
              myButton(Icons.undo, 
                onPress: (){
                  textEditingControllerD.text = _folder;
                  setState(() {});
                }, 
                disable: textEditingControllerD.text == _folder
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
        if(f1[i] is File)
          f2.add(f1[i]);
        else 
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
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file,
            color: Colors.grey[400],
            size: 20,
          ),
          Padding(padding: EdgeInsets.only(right: 5)),
          Flexible(child: Container(
              padding: new EdgeInsets.only(right: 13.0),
              child: Text(name.replaceAll(path + "/", ""),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[400],
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
    return Column(children: [
      Row(children: [
        Material(
          child:  InkWell(
            child:Container(
              padding: const EdgeInsets.all(0.0),
              width: 40.0,
              height: 40.0,
              child: IconButton(
                icon: Icon(activeFolder == name ? Icons.folder_open : Icons.folder), // folder
                // color: !_controller!.value.isPlaying ?  Colors.black54 : Colors.grey.shade300,
                iconSize: 25,
                onPressed: () {
                  activeFolder = name;
                  setState(() { });
                },
              )
            ),
          )
        ),
        Material(
        child:  InkWell(
          onTap: (){
            textEditingControllerD.text = name.replaceAll(path + "/", "");
            setState(() { });
          },
          // splashColor: Colors.red,
          child: Container(
            // padding: EdgeInsets.all(10),
            child: Text(name.replaceAll(path + "/", ""),
                  style: TextStyle(
                    // color: Colors.red,
                    fontSize: 20,
                  ),
                ),
            )
          )
        )
      ]),
      if(activeFolder == name)
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
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: disable == false ? Colors.black54 : Colors.grey.shade300, width: 1),
          // color: Colors.yellow,
        ),
        padding: const EdgeInsets.all(0.0),
        child: Container(
          padding: const EdgeInsets.all(0.0),
          width: 40.0,
          height: 40.0,
          child: IconButton(
            padding: const EdgeInsets.all(0.0),
            icon: Icon(icon),
            color: disable == false ?  Colors.black54 : Colors.grey.shade300,
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
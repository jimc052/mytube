import 'package:flutter/material.dart';
import 'package:mytube/download.dart';
import 'dart:io';
import 'package:mytube/system/system.dart';

void fileSave(BuildContext context, String url) {
  showDialog(
    barrierDismissible: false,
    context: context, 
    builder: (BuildContext context) => Panel(url: url),
  );
}

class Panel extends StatefulWidget {
  String url;
  Panel({Key? key, required this.url}) : super(key: key);

  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  Download download = new Download();
  int processing = -1;
  List files = [];
  String path = "";
  final TextEditingController textEditingControllerF = new TextEditingController();
  final TextEditingController textEditingControllerD = new TextEditingController();
  final scrollController = ScrollController();
  bool isVideo = false;
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

      try{
        loading(context, onReady: (_) {
          dialogContext = _;
        });
        await download.getVideo(this.widget.url);
        await download.getAudioStream();
        textEditingControllerF.text = trimChar(download.title);
        textEditingControllerD.text = trimChar(download.author);
        // await download.execute(onProcessing: (int process){
        //   processing = process;
        //   setState(() { });
        // });
        // print("MyTube.player.download: ${download.fileName}");
        Navigator.pop(dialogContext);
      } catch(e) {
        print("MyTube.player: $e");
      }

      if(Directory(path).existsSync()){
        List f1 = Directory(path).listSync();
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
        Directory(path).createSync();
      setState(() { });
      print("MyTube.title: ${textEditingControllerF.text}");
      print("$files");
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

    if(s.length > 50)
      s = s.substring(0, 50);
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
      body:  processing > -1 
        ? loadFile() 
        :  body(), // (download.title.length > 0  ? body() : waiting() ),
      floatingActionButton: (processing == -1 && download.title.length > 0)
        ? FloatingActionButton(
          onPressed: () async {
            await download.execute(folder: textEditingControllerD.text, fileName: textEditingControllerF.text, onProcessing: (int process){
              processing = process;
              setState(() { });
            });
          },
          child:  Icon(Icons.save_sharp, size: 30, color: Colors.white,),
        )
        : Container() 
    );

  }

  Widget loadFile(){ // 還沒寫
    return Container();
  }

  Widget body(){
    return Container(
      padding: EdgeInsets.all(10.0), //容器内补白
      child: Column(
        children:  [
          TextField(
            controller: textEditingControllerF,
            onChanged: (text) {
              // print('檔案名稱: $text');
            },
            decoration: new InputDecoration(
              hintText: '檔案名稱',
            ),
          ),
          TextField(
            controller: textEditingControllerD,
            onChanged: (text) {
              // print('目錄名稱: $text');
            },
            decoration: new InputDecoration(
              hintText: '目錄名稱',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(isVideo == true ? '視頻' : '音頻',
                style: TextStyle(
                  color: isVideo == true ? Colors.blue : Colors.grey[400],
                  fontSize: 16,
                )
              ),
              Container(
                width: 80,
                child: Transform.scale( scale: 1.4,
                  child: Switch(
                    value: isVideo,
                    onChanged: (value) {
                      isVideo = !isVideo;
                      download.streams = null;
                      setState(()  {
                        loadStream();
                      });
                    })
                )
              )
            ],
          ),
          if(download.streams != null)
            download.gridView(context, onReady: () {
              
            }, onPress: (index) {

            }),
        ]
      )
    );
  }

  loadStream() async {
    loading(context, onReady: (_) {
        dialogContext = _;
      });
    if(isVideo == true)
      await download.getVideoStream();
    else 
      await download.getAudioStream();
    
    setState(() {
      Navigator.pop(dialogContext);
    });
  }
  Widget fileList(){
    return Expanded( flex: 1,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index){ 
          return Container(
            padding: EdgeInsets.only(top: 0.0),
            child: files[index] is File
              ? widgetFile((files[index] as File).path)
              : widgetDirectory((files[index] as Directory).path)
            ,
          );
        },
      )
    );
  }
  
  Widget widgetFile(String name){
    return Container(
      padding: EdgeInsets.all(10),
      child:Row(
        children: [
          Icon(
            Icons.insert_drive_file,
            color: Colors.grey[400],
            size: 20,
          ),
          Padding(padding: EdgeInsets.only(right: 5)),
          Text(name.replaceAll(path + "/", ""),
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 20,
            ),
          ),
        ],
      )
    );
  }
  Widget widgetDirectory(String name){
    return Material(
      child:  InkWell(
        onTap: (){
          textEditingControllerD.text = name.replaceAll(path + "/", "");
        },
        // splashColor: Colors.red,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(
                Icons.folder,
                color: Colors.grey[500],
                size: 20,
              ),
              Padding(padding: EdgeInsets.only(right: 5)),
              Text(name.replaceAll(path + "/", ""),
                style: TextStyle(
                  // color: Colors.red,
                  fontSize: 20,
                ),
              ),
            ],
          )
        )
      )
    );
  }
}

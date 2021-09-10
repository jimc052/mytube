import 'package:flutter/material.dart';
import 'package:mytube/download.dart';
import 'dart:io';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    path = await Download.folder();

    try{
      // download.fileName = await Storage.getString("fileName");
      //  download.title = await Storage.getString("title");
      //  download.author = await Storage.getString("author");
      //  download.duration = Duration(milliseconds: await Storage.getInt("duration"));
      await download.getVideo(this.widget.url);
      textEditingControllerF.text = trimChar(download.title);
      textEditingControllerD.text = trimChar(download.author);
      // await download.execute(onProcessing: (int process){
      //   processing = process;
      //   setState(() { });
      // });
      // print("MyTube.player.download: ${download.fileName}");
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

      setState(() {
      });      
    }

    print("$files");
  }

  String trimChar(String s) {
    return "";
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
    return processing >-1 
      ? loading() 
      : (textEditingControllerF.text.length > 0 
        ? body() 
        : waiting()
      );
  }

  Widget loading(){
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
      body: Container( ),
    );
  }

  Widget waiting(){
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
      body: Center( 
        child: new SizedBox(
          width: 250.0,
          height: 120.0,
          child: new Container(
            decoration: ShapeDecoration(
              color: Color(0xffffffff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new CircularProgressIndicator(),
                // new Padding(
                //   padding: const EdgeInsets.only(top: 20.0),
                //   child: "loading",
                // ),
              ],
            ),
          ),
        ),
      )
    );
  }

  Widget body(){
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
      body: Container(
        padding: EdgeInsets.all(10.0), //容器内补白
        child: Column(
          children:  [
            TextField(
              controller: textEditingControllerF,
              onChanged: (text) {
                print('First text field: $text');
              },
              decoration: new InputDecoration(
                hintText: '檔案名稱',
              ),
            ),
            TextField(
              controller: textEditingControllerD,
              onChanged: (text) {
                print('First text field: $text');
              },
              decoration: new InputDecoration(
                hintText: '目錄名稱',
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            Expanded( flex: 1,
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
            )
          ]
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         
        },
        child: Icon(Icons.save_sharp, size: 30, color: Colors.white,),
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
        onTap: (){},
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

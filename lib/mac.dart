import 'package:flutter/material.dart';
import 'dart:async';


class Mac extends StatefulWidget {
  Mac({Key? key}) : super(key: key);

  @override
  _MacState createState() => _MacState();
}

class _MacState extends State<Mac> {
 

  @override
  void initState() {
    super.initState();
    
  }

  
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    
  }

  @override
  void reassemble() async {
    super.reassemble();
    // fileSave(context, url + "/watch?v=sTjJ1LlviKM");
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
        padding: EdgeInsets.only(top: 24.0),
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
          body: Text("Jim"),
        )
      )
    );
  }

  Future<bool> _onWillPop() async {
    
      return Future.value(false); // 表示不退出
      // return Future.value(true);
  }

}

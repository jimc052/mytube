import 'package:flutter/material.dart';

void alert(BuildContext context, String msg, {List<dynamic>? actions}) {
  List<Widget> _actions = [];
  print("MyTube.alert: $msg");
  Widget title =
    Container(child: 
      Row(children: <Widget>[
        // Icon(
        //   Icons.warning,
        //   color: Colors.red,
        //   size: 30,
        // ),
        // Padding(padding: EdgeInsets.only(right: 10)),
        Text("MyTube",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ],
    ),
    margin: const EdgeInsets.only(bottom: 10.0),
    padding: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      color: Colors.blue,
    //   border: Border(bottom: BorderSide( //                   <--- left side
    //     color: Colors.grey.shade500,
    //     width: 2.0,
    //   ),)
    ),
  );
  if(actions == null) {
    _actions = [
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context, true);
        },
        child: Text( "確定"),
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold
          )
        ),
      )
    ];
  } else {
    for(int i = 0; i < actions.length; i++) {
      if(actions[i].text is String) {
        _actions.add(
          ElevatedButton(
            onPressed: () {
              if(actions[i].onPressed is Function) {
                actions[i].onPressed();
              }
              Navigator.pop(context);
            },
            child: Text(actions[i].text),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold
              )
            ),
          )
          /////
        );
      }
    }
  }
  AlertDialog dialog = AlertDialog(
    // title: Text("MyTube"),
    backgroundColor: Colors.white,
    contentPadding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
    content: Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, ),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Text(msg,
                    style: TextStyle(
                      // color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
                )
              )
            )
          ],
        )
    ),
    actions: _actions,
  );

  showDialog(
    barrierDismissible: false,
    context: context, 
    builder: (BuildContext context) => dialog,
  );
}
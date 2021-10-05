import 'package:flutter/material.dart';

void alert(BuildContext context, String msg, {List<Widget>? actions}) {
  print("MyTube.alert: $msg");
  Widget objTitle =
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
            color: Colors.blue,
            fontSize: 20,
          ),
        ),
      ],
    ),
    margin: const EdgeInsets.only(bottom: 10.0),
    padding: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide( //                   <--- left side
        color: Colors.grey.shade500,
        width: 2.0,
      ),)
    ),
  );
  if(actions == null) {
    actions = [
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context, true);
        },
        child: Text(
          "確定",
          // style: TextStyle(color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.purple,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold
          )
        ),
      )
    ];
  }
  AlertDialog dialog = AlertDialog(
    title: Text("MyTube"),
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
          objTitle,
          Text(msg,
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
            ),
          ),
      ],)
    ),
    actions: actions,
  );

  showDialog(
    barrierDismissible: false,
    context: context, 
    builder: (BuildContext context) => dialog,
  );
}
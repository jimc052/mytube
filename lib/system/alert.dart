import 'package:flutter/material.dart';

void alert(BuildContext context, String msg) {
    AlertDialog dialog = AlertDialog(
      backgroundColor: Colors.yellow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      content: Container(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 30,
            ),
            Padding(padding: EdgeInsets.only(right: 10)),
            Text(msg,
              style: TextStyle(
                color: Colors.red,
                fontSize: 30,
              ),
            ),
          ],
        )
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(
            "CLOSE",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );

    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (BuildContext context) => dialog,
    );
  }
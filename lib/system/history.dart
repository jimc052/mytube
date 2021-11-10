import 'dart:convert';

import 'package:mytube/system/storage.dart';

class History {
  String title, author, date;
  int position;

  History(this.title, this.author, this.date, this.position);

  Map<String, dynamic> toJson() => {
    "title": title,
    "author": author,
    "date": date,
    "position": position
  };
}
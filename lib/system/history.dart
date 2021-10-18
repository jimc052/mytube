import 'dart:convert';

import 'package:mytube/system/storage.dart';

class History {
  String key, title, author, date, position;

  History(this.key, this.title, this.author, this.date, this.position);

  Map<String, dynamic> toJson() => {
    'key': key,
    "title": title,
    "author": author,
    "date": date,
    "position": position
  };
}
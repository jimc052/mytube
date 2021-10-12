import 'package:intl/intl.dart';

extension DateTimeParse on DateTime{
	String formate({String pattern = "yyyy/MM/dd HH:mm:ss"}){
    DateFormat formatter = DateFormat(pattern);
    return formatter.format(this);
	}
}

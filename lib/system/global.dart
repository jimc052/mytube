library mytube.global;

import 'dart:ui';

var pixelRatio = window.devicePixelRatio;
var width = window.physicalSize.width;
var screenSize = window.physicalSize;

bool isLargeScreen(){
  return window.physicalSize.width > 1200 || window.physicalSize.height > 1200;
}
// print("MyTube.width: ${width}");
// var physicalWidth = physicalScreenSize.width;
// var physicalHeight = physicalScreenSize.height;
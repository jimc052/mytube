package com.tw.mytube;

import android.app.Application;
import android.content.Context;
import android.os.Build;
import android.os.Environment;

import java.io.File;
import android.webkit.WebView;

public class MainApplication extends Application  {
  static public String rootPath(){ // 取得外部儲存裝置路徑
    String path = Environment.getExternalStorageDirectory().getAbsolutePath() +
            File.separator + "MyTube";

    // Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath();

    return path;
  }


  @Override
  public void onCreate() {
    super.onCreate();
    MyExceptionHandler.getInstance().init(this);
    WebView.setWebContentsDebuggingEnabled(true);
  }


}

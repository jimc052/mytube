package com.tw.mytube;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Environment;
import android.util.Log;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  public static String TAG = "MyTube";
  public static EventChannel.EventSink eventSink;
  HeadsetReceiver headsetReceiver;


  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);

    new MethodChannel(
            flutterEngine.getDartExecutor(),
            "com.flutter/MethodChannel")
            .setMethodCallHandler(mMethodHandle);
    new EventChannel(flutterEngine.getDartExecutor(),
            "com.flutter/EventChannel")
            .setStreamHandler(mEnventHandle);

    IntentFilter filter = new IntentFilter(Intent.ACTION_HEADSET_PLUG);
    headsetReceiver = new HeadsetReceiver();
    registerReceiver(headsetReceiver, filter);

  }
  MethodChannel.MethodCallHandler mMethodHandle = new MethodChannel.MethodCallHandler() {
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
      //  Log.i(TAG, "method: " + call.method);
//      _result = result;
      if(call.method.equals("execCmd")) { //
        MainActivity.execCmd(call.argument("cmd"));
        result.success("OK"); // call.argument("path")));
      } else if(call.method.equals("finish")) { // 結束程式
        Log.i(TAG, "method: " + call.method);
        result.success("OK"); // call.argument("path")));
        finish();
      } else if (call.method.equals("getDownloadsDirectory")) {
          result.success(getDownloadsDirectory());
      } else
        result.notImplemented();
    }
  };

  private String getDownloadsDirectory() {
    return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath();
  }

  EventChannel.StreamHandler mEnventHandle = new EventChannel.StreamHandler() {
    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
      MainActivity.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
    }
  };
  private class HeadsetReceiver extends BroadcastReceiver { // 耳機
    @Override public void onReceive(Context context, Intent intent) {

      String action = intent.getAction();
      if (action == null) {
        return;
      } else if (action.equals(Intent.ACTION_HEADSET_PLUG)) {
        int state = intent.getIntExtra("state", -1);
        switch (state) {
          case 0:
//             Log.d(TAG, "Headset is unplugged");
              if(MainActivity.eventSink != null)
                MainActivity.eventSink.success("unplugged");
            break;
          case 1:
//             Log.d(TAG, "Headset is plugged");
            break;
          default:
            Log.d(TAG, "I have no idea what the headset state is");
        }
      }
    }
  }
  @Override
  protected void onResume() {
    super.onResume();
    if(MainActivity.eventSink != null)
      MainActivity.eventSink.success("onResume");
  }

  @Override
  protected void onPause() {
    super.onPause();
    if(MainActivity.eventSink != null)
      MainActivity.eventSink.success("onPause");
  }

  @Override
  protected void onStop() {
    super.onStop();
    if(MainActivity.eventSink != null)
      MainActivity.eventSink.success("onStop");
  }
  @Override
  protected void onDestroy() {
    super.onDestroy();
    unregisterReceiver(headsetReceiver);
//    MainActivity.eventSink.success("onDestroy");
  }


  public static boolean execCmd(String cmd) { // 不用了，直接用 js
    Log.i(TAG, "execCmd..........." + cmd);
    try{
      Process p = Runtime.getRuntime().exec("sh");  //su為root使用者,sh普通使用者
      OutputStream outputStream = p.getOutputStream();
      DataOutputStream dataOutputStream=new DataOutputStream(outputStream);
      dataOutputStream.writeBytes(cmd);
      dataOutputStream.flush();
      dataOutputStream.close();
      outputStream.close();
      return true;
    }
    catch(Throwable t) {
      t.printStackTrace();
      Log.i(TAG, "execCmd: " + t.getMessage());
    }
    return false;
  }
}

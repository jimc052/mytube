package com.tw.mytube;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Environment;
import android.util.Log;

import android.view.View;
import android.widget.RemoteViews;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;

import androidx.annotation.NonNull;

import androidx.core.app.NotificationCompat;
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
  String mode = "close", title = "", author = "", position = "";

  // public static final String ACTION_PLAY = "action.PLAY";
  public static final String ACTION_TOGGLE = "action.TOGGLE";
  public static final String ACTION_STOP = "action.STOP";
  public static final String ACTION_SELECT = "action.SELECT";
  public static final String ACTION_NEXT = "action.NEXT";
  public static final String ACTION_PREV = "action.PREV";
  private static final String CHANNEL = "media_notification";
  public static NotificationManager mNM;
  public static String versionName = "";
  String path = "";
  MethodChannel.Result _result;

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
    mNM = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);
    createNotificationChannel();

    try {
      PackageInfo pInfo = this.getPackageManager().getPackageInfo(this.getPackageName(), 0);
      versionName = pInfo.versionName;
    } catch (PackageManager.NameNotFoundException e) {
      e.printStackTrace();
    }
  }
  MethodChannel.MethodCallHandler mMethodHandle = new MethodChannel.MethodCallHandler() {
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
      if(call.method.equals("play")) {
        mode = "play";
        title = call.argument("title");
        author = call.argument("author");
        position = call.argument("position");
        showNotification();
      } else if(call.method.equals("pause")) {
        mode = "pause";
        showNotification();
      } else if(call.method.equals("stop")) {
        mode = "stop";
        mNM.cancel(1);
      } else if(call.method.equals("finish")) { // 結束程式
        Log.i(TAG, "method: " + call.method);
        result.success("OK"); // call.argument("path")));
        finish();
      } else if (call.method.equals("getDownloadsDirectory")) {
        String path = MainApplication.rootPath();
        createFolder(path);
        result.success(path);
      } else if (call.method.equals("getVersionName")) {
        result.success(versionName);
      } else
        result.notImplemented();
    }
  };

  private String getDownloadsDirectory() { //
    return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath();
  }

//
  private void createFolder(String path) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      File tDataPath = new File(path);
      //識別指定的目錄是否存在，false則建立；
      if (tDataPath.exists() == false) {
        tDataPath.mkdir();
      }
    } else {
      File tDataPath = new File(path);
      //識別指定的目錄是否存在，false則建立；
      if (tDataPath.exists() == false) {
        tDataPath.mkdir();
      }
    }
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
              if(MainActivity.eventSink != null)
                MainActivity.eventSink.success("unplugged");
            break;
          case 1:
              if(MainActivity.eventSink != null)
                MainActivity.eventSink.success("plugged");
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
    mNM.cancel(1);
  }
  @Override
  protected void onDestroy() {
    super.onDestroy();
    unregisterReceiver(headsetReceiver);
	  mNM.cancel(1);
//    MainActivity.eventSink.success("onDestroy");
  }
  private void createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      int importance = NotificationManager.IMPORTANCE_LOW;
      NotificationChannel channel = new NotificationChannel(CHANNEL, CHANNEL, importance);
      mNM.createNotificationChannel(channel);
    }
  }
  private void showNotification() {
    NotificationCompat.Builder nBuilder = new NotificationCompat.Builder(this, CHANNEL)
      .setSmallIcon(R.drawable.ic_stat_music_note)
      .setPriority(Notification.PRIORITY_DEFAULT)
      .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
      .setOnlyAlertOnce(true)
      .setVibrate(new long[]{0L})
      .setSound(null);
    RemoteViews remoteView = new RemoteViews(this.getPackageName(), R.layout.notificationlayout);

    remoteView.setTextViewText(R.id.title, title);
    remoteView.setTextViewText(R.id.author, author); 
    remoteView.setTextViewText(R.id.index, position); 
    remoteView.setViewVisibility(R.id.prev, View.GONE); // // View.VISIBLE
    remoteView.setViewVisibility(R.id.next, View.GONE);

    String icon = mode.equals("play") ? "baseline_pause_black_48" : "baseline_play_arrow_black_48";
    remoteView.setImageViewResource(R.id.toggle, getResources()
      .getIdentifier(icon,"drawable", this.getPackageName()));

    setNotificationListeners(remoteView);
    nBuilder.setContent(remoteView);

    Notification notification = nBuilder.build();
    mNM.notify(1, notification);
  }

  void setNotificationListeners(RemoteViews view){
    Intent intent = new Intent(MainActivity.this, NotificationReturnSlot.class).setAction(ACTION_TOGGLE);
    PendingIntent pendingIntent = PendingIntent.getBroadcast(MainActivity.this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    view.setOnClickPendingIntent(R.id.toggle, pendingIntent);

    Intent nextIntent = new Intent(MainActivity.this, NotificationReturnSlot.class).setAction(ACTION_NEXT);
    PendingIntent pendingNextIntent = PendingIntent.getBroadcast(MainActivity.this, 0, nextIntent, PendingIntent.FLAG_UPDATE_CURRENT);
    view.setOnClickPendingIntent(R.id.next, pendingNextIntent);

    Intent prevIntent = new Intent(MainActivity.this, NotificationReturnSlot.class).setAction(ACTION_PREV);
    PendingIntent pendingPrevIntent = PendingIntent.getBroadcast(MainActivity.this, 0, prevIntent, PendingIntent.FLAG_UPDATE_CURRENT);
    view.setOnClickPendingIntent(R.id.prev, pendingPrevIntent);

    Intent closeIntent = new Intent(MainActivity.this, NotificationReturnSlot.class).setAction(ACTION_STOP);
    PendingIntent pendingCloseIntent = PendingIntent.getBroadcast(MainActivity.this, 0, closeIntent, PendingIntent.FLAG_UPDATE_CURRENT);
    view.setOnClickPendingIntent(R.id.close, pendingCloseIntent);

    Intent selectIntent = new Intent(MainActivity.this, NotificationReturnSlot.class).setAction(ACTION_SELECT);
    PendingIntent selectPendingIntent = PendingIntent.getBroadcast(MainActivity.this, 0, selectIntent, PendingIntent.FLAG_CANCEL_CURRENT);
    view.setOnClickPendingIntent(R.id.layout, selectPendingIntent);
  }

  public static class NotificationReturnSlot extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
      if (action == null) {
        return;
      }
      Log.i(TAG, action);
      if (action.equals(ACTION_SELECT)) {
        Intent closeDialog = new Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS);
        context.sendBroadcast(closeDialog);
        String packageName = context.getPackageName();
        PackageManager pm = context.getPackageManager();
        Intent launchIntent = pm.getLaunchIntentForPackage(packageName);
        context.startActivity(launchIntent);
      } else {
        MainActivity.eventSink.success(action);
        if (action.equals(ACTION_STOP))
          MainActivity.mNM.cancel(1);
      }
    }
  }
}

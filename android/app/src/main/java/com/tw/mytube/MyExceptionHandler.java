package com.tw.mytube;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Looper;
import android.os.SystemClock;
import android.util.Log;
import android.widget.Toast;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;

public class MyExceptionHandler implements Thread.UncaughtExceptionHandler {
	private String TAG = "ReactNative-MyExceptionHandler";
	private Context context;
	private Thread.UncaughtExceptionHandler mUncaughtExceptionHandler;
	private static MyExceptionHandler instance = new MyExceptionHandler();

	private MyExceptionHandler() {
	}

	/**
	 * 获取CrashHandler实例 ,单例模式
	 */
	public static MyExceptionHandler getInstance() {
		return instance;
	}

	public void init(Context context) {
		this.context = context;
		mUncaughtExceptionHandler = Thread.getDefaultUncaughtExceptionHandler();// 获取系统默认的异常处理类
		Thread.setDefaultUncaughtExceptionHandler(this);

	}

	@Override
	public void uncaughtException(Thread thread, Throwable ex) {

		if (!handleException(ex) && mUncaughtExceptionHandler != null) {
			// 若是用户没有设置异常处理，则让系统默认的类来处理异常
			mUncaughtExceptionHandler.uncaughtException(thread, ex);
		} else {
			// 进行自定义的方法
			// 设置定时任务，1秒后重启此 App
			Intent intent = new Intent(context, MainActivity.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			PendingIntent restartIntent = PendingIntent.getActivity(context, 0, intent, 0);
			AlarmManager mAlarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
			mAlarmManager.set(AlarmManager.RTC, System.currentTimeMillis() + 1000, restartIntent);
			// 移除当前任务
			android.os.Process.killProcess(android.os.Process.myPid());
			System.exit(1);
		}
	}


	private boolean handleException(Throwable ex) {
		if (ex == null) {
			return false;
		}
		uncaughtException(ex.getLocalizedMessage());

		new Thread() {
			@Override
			public void run() {
				Looper.prepare();
				Toast.makeText(context,"很抱歉，MyTube 程式異常, 5 秒鐘後重啟。",Toast.LENGTH_LONG).show();
				Looper.loop();
			}
		}.start();
		SystemClock.sleep(3000);
		return true;
	}

	void uncaughtException(String ex) {
		Log.e(TAG, ex);
		Date date = new Date();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		SimpleDateFormat sdf2 =new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		final String fileName = sdf.format(date) + ".txt";
		final String data = "******************************\n" +
						sdf2.format(date) + "\n" + ex +
						"\n******************************\n";

		String folder =  MainApplication.rootPath();
		createFolder(folder);

		folder += "/" + "Log";
		createFolder(folder);

		try {
			OutputStream out = new FileOutputStream(folder + "/" + fileName, true);
			out.write(data.getBytes());
			out.flush(); out.close();
			out = null;
		} catch (Exception e) {
			Log.e(TAG, "Failed to write file: " + fileName, e);
		} finally {

		}
	}
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

}
package com.nadiaferdoush.device_details_plugin;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.graphics.Point;
import android.os.Build;
import android.os.Environment;
import android.os.StatFs;
import android.telephony.TelephonyManager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.WindowManager;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * DeviceDetailsPlugin
 * Note 01
 * If your plugin needs to interact with the UI, such as requesting permissions,
 * or altering Android UI chrome, then you need to take additional steps to define your plugin.
 * You must implement the ActivityAware interface.
 */
public class DeviceDetailsPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    private static Context context;
    private static Activity activity;

    @Override
    public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
        final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "device_details_plugin");
        channel.setMethodCallHandler(new DeviceDetailsPlugin());
        context = flutterPluginBinding.getApplicationContext();
    }


    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "device_details_plugin");
        channel.setMethodCallHandler(new DeviceDetailsPlugin());
        context = registrar.activity().getApplication();
        activity = registrar.activity();
    }

    @TargetApi(Build.VERSION_CODES.M)
    @SuppressLint("HardwareIds")
    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("getAndroidInfo")) {
            Map<String, Object> androidInfo = new HashMap<>();
            androidInfo.put("osVersion", Build.VERSION.SDK_INT);
            androidInfo.put("totalInternalStorage", getInternalMemoryInfo("totalInternal"));
            androidInfo.put("freeInternalStorage", getInternalMemoryInfo("freeInternal"));
            androidInfo.put("mobileNetwork", getMobileNetwork());
            androidInfo.put("totalRamSize", getRAMInfo("totalRAM"));
            androidInfo.put("freeRamSize", getRAMInfo("freeRAM"));
            androidInfo.put("screenSize", getScreenSizeInches());
            androidInfo.put("dateAndTime", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Calendar.getInstance().getTime()));
            androidInfo.put("manufacturer", Build.MANUFACTURER);
            /*androidInfo.put("osVersion", Build.VERSION_CODES.class.getFields()[android.os.Build.VERSION.SDK_INT].getName());
            androidInfo.put("device", Settings.Secure.getString(context.getContentResolver(),
                    Settings.Secure.ANDROID_ID));
            androidInfo.put("modelAndProduct", Build.MODEL + "(" + Build.PRODUCT + ")");*/
            Log.v("'androidInfo'", androidInfo.toString());
            result.success(androidInfo);
        } else {
            result.notImplemented();
        }
    }

    @SuppressLint("DefaultLocale")
    private static String humanReadableByteCountSI(long bytes) {
        String s = bytes < 0 ? "-" : "";
        long b = bytes == Long.MIN_VALUE ? Long.MAX_VALUE : Math.abs(bytes);
        return b < 1000L ? bytes + " B"
                : b < 999_950L ? String.format("%s%.1f kB", s, b / 1e3)
                : (b /= 1000) < 999_950L ? String.format("%s%.1f MB", s, b / 1e3)
                : (b /= 1000) < 999_950L ? String.format("%s%.1f GB", s, b / 1e3)
                : (b /= 1000) < 999_950L ? String.format("%s%.1f TB", s, b / 1e3)
                : (b /= 1000) < 999_950L ? String.format("%s%.1f PB", s, b / 1e3)
                : String.format("%s%.1f EB", s, b / 1e6);
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private static String getRAMInfo(String infoType) {
        String ramInfo = "";
        ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        if (activityManager != null) {
            activityManager.getMemoryInfo(memoryInfo);
        }
        switch (infoType) {
            case "totalRAM":
                ramInfo = humanReadableByteCountSI(memoryInfo.totalMem);
                break;
            case "freeRAM":
                ramInfo = humanReadableByteCountSI(memoryInfo.availMem);
                break;
        }
        return ramInfo;
    }

    private static String getInternalMemoryInfo(String infoType) {
        StatFs statFs = new StatFs(Environment.getRootDirectory().getAbsolutePath());
        String memoryInfo = "";
        long blockSize;
        long availableBlocks;
        long totalBlocks;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR2) {
            blockSize = statFs.getBlockSizeLong();
            availableBlocks = statFs.getAvailableBlocksLong();
            totalBlocks = statFs.getBlockCountLong();
        } else {
            blockSize = statFs.getBlockSize();
            availableBlocks = statFs.getAvailableBlocks();
            totalBlocks = statFs.getBlockCount();
        }
        switch (infoType) {
            case "totalInternal":
                memoryInfo = humanReadableByteCountSI(totalBlocks * blockSize);
                break;
            case "freeInternal":
                memoryInfo = humanReadableByteCountSI(availableBlocks * blockSize);
                break;
        }
        return memoryInfo;
    }

    private static String getScreenSizeInches() {
        double x = 0, y = 0;
        int mWidthPixels, mHeightPixels;
        try {
            WindowManager windowManager = activity.getWindowManager();
            Display display = windowManager.getDefaultDisplay();
            DisplayMetrics displayMetrics = new DisplayMetrics();
            display.getMetrics(displayMetrics);
            Point realSize = new Point();
            Display.class.getMethod("getRealSize", Point.class).invoke(display, realSize);
            mWidthPixels = realSize.x;
            mHeightPixels = realSize.y;
            DisplayMetrics dm = new DisplayMetrics();
            activity.getWindowManager().getDefaultDisplay().getMetrics(dm);
            x = Math.pow(mWidthPixels / dm.xdpi, 2);
            y = Math.pow(mHeightPixels / dm.ydpi, 2);
        } catch (Exception ignored) {
        }
        return String.format(Locale.US, "%.1f", Math.sqrt(x + y));
    }

    private static String getMobileNetwork() {
        TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
        return telephonyManager != null ? telephonyManager.getNetworkOperatorName() : null;
    }

    //your plugin is now attached to an Activity
    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        activity = activityPluginBinding.getActivity();
    }

    // the Activity your plugin was attached to was destroyed to change configuration.
    // This call will be followed by onReattachedToActivityForConfigChanges().
    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    // your plugin is now attached to a new Activity after a configuration change.
    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {

    }

    // your plugin is no longer associated with an Activity. Clean up references.
    @Override
    public void onDetachedFromActivity() {

    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        //tearDownChannel()
    }

}

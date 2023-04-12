package com.example.video_edit

import android.annotation.TargetApi
import androidx.annotation.NonNull
import com.arthenica.mobileffmpeg.FFmpeg

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import java.io.File
import java.time.format.DateTimeFormatter;
import java.time.LocalDateTime;

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.util.Log
import android.graphics.Color


/** VideoEditPlugin */
class VideoEditPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private val TAG = "VideoEditor"
  private val RETURN_CODE_SUCCESS = 0

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "video_edit")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${VERSION.RELEASE}")
    }else if (call.method == "getBatteryLevel"){
      val batteryLevel = getBatteryLevel()
        if (batteryLevel != -1) {
          result.success(batteryLevel)
        } else {
          result.error("UNAVAILABLE", "Battery level not available.", null)
        }
    } else if (call.method == "addImageToVideo"){
      val videoPath: String = call.argument("videoPath")?:""
      val imagePath: String = call.argument("imagePath")?:""
      val x: Int = call.argument("x")?:0
      val y: Int = call.argument("y")?:0
      val add = addImageToVideo(videoPath, imagePath, x, y)
      result.success(add)
    } else if (call.method == "addTextToVideo"){
      val videoPath: String = call.argument("videoPath")?:""
      val text: String = call.argument("text")?:""
      val x: Int = call.argument("x")?:0
      val y: Int = call.argument("y")?:0
      val add = addTextToVideo(videoPath, text, x, y)
      result.success(add)
    } else if (call.method == "addShapesToVideo"){
      val videoPath: String = call.argument("videoPath")?:""
      val add = addShapesToVideo(videoPath)
      result.success(add)
    } else{
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun getBatteryLevel(): Int {
    val batteryLevel: Int
    if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
      val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
      batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    } else {
      val intent = ContextWrapper(context).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
      batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
    }

    return batteryLevel
  }

  @TargetApi(VERSION_CODES.O)
  fun colorToRgb(color: Color): String {
    return listOf(color.red(), color.green(), color.blue()).joinToString(":")
  }

  @TargetApi(VERSION_CODES.O)
  private fun addImageToVideo(videoPath: String, imagePath: String, x: Int, y: Int): String? {
    val videoFile = File(videoPath)
    if (!videoFile.exists()) {
      Log.e(TAG, "addImageToVideo: Video file not found")
      return null
    }

    val imageFile = File(imagePath)
    if (!imageFile.exists()) {
      Log.e(TAG, "addImageToVideo: Image file not found")
      return null
    }
    val formatter = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmssSSS")
    val current = LocalDateTime.now().format(formatter)

    val outputPath = "${context.getCacheDir()}/$current.mp4"

    val commands = ArrayList<String>()
    commands.add("-i")
    commands.add(videoPath)
    commands.add("-i")
    commands.add(imagePath)
    commands.add("-filter_complex")
    commands.add("[1:v]scale=100:-1[ovrl], [0:v][ovrl]overlay=$x:$y")
    commands.add("-codec:a")
    commands.add("copy")
    commands.add("-preset")
    commands.add("ultrafast")
    commands.add("-strict")
    commands.add("-2")
    commands.add(outputPath)

    val rc = FFmpeg.execute(commands.toTypedArray())
    return if (rc == RETURN_CODE_SUCCESS) {
      Log.i(TAG, "addImageToVideo: Video processing succeeded")
      outputPath
    } else {
      Log.e(TAG, "addImageToVideo: Video processing failed with rc=$rc")
      null
    }
  }


  @TargetApi(VERSION_CODES.O)
  private fun addTextToVideo(videoPath: String, text: String, x: Int, y: Int): String? {
    val videoFile = File(videoPath)
    if (!videoFile.exists()) {
      Log.e(TAG, "addTextToVideo: Video file not found")
      return null
    }
    val formatter = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmssSSS")
    val current = LocalDateTime.now().format(formatter)

    val outputPath = "${context.cacheDir}/$current.mp4"

    val commands = ArrayList<String>()
    commands.add("-i")
    commands.add(videoPath)
    commands.add("-vf")
    commands.add("drawtext=fontfile=/system/fonts/Roboto-Regular.ttf:text='$text':fontcolor=red:fontsize=50:x=$x:y=$y")
    commands.add("-codec:a")
    commands.add("copy")
    commands.add("-preset")
    commands.add("ultrafast")
    commands.add("-strict")
    commands.add("-2")
    commands.add(outputPath)

    val rc = FFmpeg.execute(commands.toTypedArray())
    return if (rc == RETURN_CODE_SUCCESS) {
      Log.i(TAG, "addTextToVideo: Video processing succeeded")
      outputPath
    } else {
      Log.e(TAG, "addTextToVideo: Video processing failed with rc=$rc")
      null
    }
  }

  @TargetApi(VERSION_CODES.O)
  private fun addShapesToVideo(videoPath: String): String? {
    
    val videoFile = File(videoPath)
    if (!videoFile.exists()) {
      Log.e(TAG, "addTextToVideo: Video file not found")
      return null
    }
    val formatter = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmssSSS")
    val current = LocalDateTime.now().format(formatter)

    val outputPath = "${context.cacheDir}/$current.mp4"

    val commands = ArrayList<String>()
    commands.add("-i")
    commands.add(videoPath)
    commands.add("-vf")
    commands.add("drawline=x1=100:y1=100:x2=300:y2=100:color=yellow@0.5:thickness=5")
    commands.add("-vf")
    commands.add("drawcircle=x=250:y=250:r=50:color=red@0.5:thickness=5")
    commands.add("-vf")
    commands.add("drawbox=x=50:y=200:w=200:h=100:color=green@0.5:thickness=5")
    commands.add("-codec:a")
    commands.add("copy")
    commands.add("-preset")
    commands.add("ultrafast")
    commands.add("-strict")
    commands.add("-2")
    commands.add(outputPath)

    val rc = FFmpeg.execute(commands.toTypedArray())
    return if (rc == RETURN_CODE_SUCCESS) {
      Log.i(TAG, "addShapesToVideo: Video processing succeeded")
      outputPath
    } else {
      Log.e(TAG, "addShapesToVideo: Video processing failed with rc=$rc")
      null
    }
  }
}

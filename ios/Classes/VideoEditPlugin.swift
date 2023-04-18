import Flutter
import UIKit
import AVFoundation
import CoreMedia
import PromiseKit

public class VideoEditPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "video_edit", binaryMessenger: registrar.messenger())
    let instance = VideoEditPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
    case "addImageToVideo":
        guard let args = call.arguments as? [String: Any],
              let path = args["videoPath"] as? String,
              let text = args["text"] as? String,
              let imagePath = args["imagePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        print("TOP")
        
        let videoProcessor = VideoProcessor()
        firstly {
            videoProcessor.processVideo(atPath: path, withText: text, andImage: UIImage(contentsOfFile: imagePath)!)
        }.done { outputFilePath in
            // Do something with the output file
            result(outputFilePath)
        }.catch { error in
            // Handle the error
            result(FlutterError(code: "VIDEO_PROCESSING_ERROR", message: error.localizedDescription, details: nil))
        }
    case "addImageToVideo2":
      guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String,
              let videoPath = args["videoPath"] as? String,
              let x = args["x"] as? Double,
              let y = args["y"] as? Double else {
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }
        if let image = UIImage(contentsOfFile: imagePath){
            let videoProcessor = VideoProcessor()
            let text = "Hello, world!"
            firstly {
                videoProcessor.addImageToVideo(atPath: videoPath, withText: text, andImage: image, atFrame: CGRect(x: 100, y: 100, width: 200, height: 200))
            }.done { outputFilePath in
                // Do something with the output file
                result(outputFilePath)
            }.catch { error in
                // Handle the error
                result(FlutterError(code: "VIDEO_PROCESSING_ERROR", message: error.localizedDescription, details: nil))
            }
        } else {
            result(FlutterError(code: "invalid_file_path", message: "Invalid file path", details: nil))
        }
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}

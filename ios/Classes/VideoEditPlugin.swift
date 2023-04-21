import Flutter
import UIKit
import AVFoundation
import CoreMedia
import PromiseKit

public class VideoEditPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "video_edit", binaryMessenger: registrar.messenger())
    let instance: VideoEditPlugin = VideoEditPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
    case "addImageToVideo":
      guard let args = call.arguments as? [String: Any],
              let videoPath = args["videoPath"] as? String else {
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }
       
        let videoProcessor: VideoProcessor = VideoProcessor()
        let text: String? = args["text"] as? String
        let imagePath: String? = args["imagePath"] as? String
        var image: UIImage? = nil
        var textPosition: Position? = nil
        var imageFrame: CGRect? = nil
        if imagePath != nil{
            image = UIImage(contentsOfFile: imagePath!)
            let imageX: Double = args["imageX"] as! Double
            let imageY: Double = args["imageY"] as! Double
            imageFrame = CGRect(x: imageX, y: imageY, width: 200, height: 200)
        }
        if text != nil{
          let textX: Double = args["textX"] as! Double
            let textY: Double = args["textY"] as! Double
            textPosition =  Position(x: textX, y: textY)
        }
        
        firstly {
            videoProcessor.addImageToVideo(atPath: videoPath, withText: text, andImage: image, atFrame: imageFrame, atPosition: textPosition)
        }.done { outputFilePath in
            // Do something with the output file
            result(outputFilePath)
        }.catch { error in
            // Handle the error
            result(FlutterError(code: "VIDEO_PROCESSING_ERROR", message: error.localizedDescription, details: nil))
        }
        
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}

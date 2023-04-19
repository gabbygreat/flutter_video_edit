import AVFoundation
import CoreMedia
import PromiseKit

class VideoProcessor {
    
    func processVideo(atPath path: String, withText text: String, andImage image: UIImage) -> Promise<String?> {
        return Promise { seal in
            let asset: AVAsset = AVAsset(url:  URL(fileURLWithPath: path))

            let composition: AVMutableComposition = AVMutableComposition()
            guard let videoTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                let audioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid),
                let assetVideoTrack: AVAssetTrack = asset.tracks(withMediaType: .video).first,
                let assetAudioTrack: AVAssetTrack = asset.tracks(withMediaType: .audio).first else {
                seal.fulfill(nil)
                return
            }

            do {
                try videoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: assetVideoTrack, at: .zero)
                try audioTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: assetAudioTrack, at: .zero)
            } catch {
                seal.fulfill(nil)
            }

            let videoSize: CGSize = assetVideoTrack.naturalSize

            let parentLayer: CALayer = CALayer()
            parentLayer.frame = CGRect(origin: .zero, size: videoSize)

            let imageLayer: CALayer = CALayer()
            imageLayer.contents = image.cgImage
            imageLayer.frame = CGRect(origin: .zero, size: videoSize)
            parentLayer.addSublayer(imageLayer)

            let textLayer: CATextLayer = CATextLayer()
            textLayer.string = text
            textLayer.font = UIFont(name: "Helvetica-Bold", size: 40)
            textLayer.alignmentMode = .center
            textLayer.frame = CGRect(x: 0, y: videoSize.height - 60, width: videoSize.width, height: 60)
            parentLayer.addSublayer(textLayer)

            let videoLayer: CALayer = CALayer()
            videoLayer.frame = CGRect(origin: .zero, size: videoSize)
            let videoAssetTrack: AVMutableCompositionTrack = composition.tracks(withMediaType: .video).first!
            let videoLayerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoAssetTrack)
            videoLayerInstruction.setTransform(videoAssetTrack.preferredTransform, at: .zero)
            videoLayerInstruction.setOpacity(0.0, at: asset.duration)
            let videoCompositionInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
            videoCompositionInstruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            videoCompositionInstruction.layerInstructions = [videoLayerInstruction]
            let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
            videoComposition.renderSize = videoSize
            videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
            videoComposition.instructions = [videoCompositionInstruction]
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)

            guard let exportSession: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
                seal.fulfill(nil)
                return
            }

            let outputURL: URL = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            exportSession.videoComposition = videoComposition

            let dispatchGroup: DispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            exportSession.exportAsynchronously(completionHandler: {
                dispatchGroup.leave()
            })

            dispatchGroup.wait()

            if exportSession.status == .completed {
                seal.fulfill(outputURL.path)
            } else {
                seal.fulfill(nil)
            }
        
        }
    }

 func addImageToVideo(atPath path: String, withText text: String, andImage image: UIImage, atFrame imageFrame: CGRect) -> Promise<String?> {
        return Promise { seal in
            let asset: AVAsset = AVAsset(url:  URL(fileURLWithPath: path))

            let composition: AVMutableComposition = AVMutableComposition()
            guard let videoTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                let audioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid),
                let assetVideoTrack: AVAssetTrack = asset.tracks(withMediaType: .video).first,
                let assetAudioTrack: AVAssetTrack = asset.tracks(withMediaType: .audio).first else {
                seal.fulfill(nil)
                return
            }

            do {
                try videoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: assetVideoTrack, at: .zero)
                try audioTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: assetAudioTrack, at: .zero)
            } catch {
                seal.fulfill(nil)
            }

            // GET THE VIDEO SIZE; HEIGHT AND WIDTH
            let videoSize: CGSize = assetVideoTrack.naturalSize

            let parentLayer: CALayer = CALayer()
            parentLayer.frame = CGRect(origin: .zero, size: videoSize)
            
            let label = UILabel()
            label.text = text
            label.font = UIFont.systemFont(ofSize: 50)
            label.sizeToFit()

            let textLayer = CATextLayer()
            textLayer.string = label.text
            textLayer.font = label.font.fontName as CFTypeRef?
            textLayer.fontSize = label.font.pointSize
            textLayer.alignmentMode = .center
            textLayer.foregroundColor = UIColor.black.cgColor

            textLayer.frame = CGRect(x: videoSize.width/2, y: videoSize.height/2, width: label.frame.width+5, height: label.frame.height)


            let imageLayer: CALayer = CALayer()
            imageLayer.contents = image.cgImage
            imageLayer.frame = imageFrame
            
            let videoLayer: CALayer = CALayer()
            videoLayer.frame = CGRect(origin: .zero, size: videoSize)
            let videoAssetTrack: AVMutableCompositionTrack = composition.tracks(withMediaType: .video).first!
            let videoLayerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoAssetTrack)
            videoLayerInstruction.setTransform(videoAssetTrack.preferredTransform, at: .zero)
            videoLayerInstruction.setOpacity(1.0, at: asset.duration)
            let videoCompositionInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
            videoCompositionInstruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            videoCompositionInstruction.layerInstructions = [videoLayerInstruction]
            let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
            videoComposition.renderSize = videoSize
            videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
            videoComposition.instructions = [videoCompositionInstruction]
            
            
             parentLayer.addSublayer(videoLayer)
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
            parentLayer.addSublayer(imageLayer)
            parentLayer.addSublayer(textLayer)
            

            guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
                seal.fulfill(nil)
                return
            }
            
            // Set the time range of the export session to the duration of the video
            exportSession.timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
            
            // Set the export session's output URL and file type
            let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            exportSession.videoComposition = videoComposition
            
            // Export the video asynchronously and fulfill the Promise with the output URL when done
            exportSession.exportAsynchronously {
                if exportSession.status == .completed {
                    seal.fulfill(outputURL.path)
                } else {
                    seal.fulfill(nil)
                }
            }
        }
    }

}

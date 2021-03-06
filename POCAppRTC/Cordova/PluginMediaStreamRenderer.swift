import Foundation
import AVFoundation
import WebKit

//class PluginMediaStreamRenderer : NSObject, RTCEAGLVideoViewDelegate {
class PluginMediaStreamRenderer : NSObject, RTCVideoViewDelegate {

    var id: String
    var eventListener: (_ data: NSDictionary) -> Void
    var closed: Bool

    var webView: WKWebView
    var elementView: UIView
    var pluginMediaStream: PluginMediaStream?

    var videoView: RTCEAGLVideoView
    var rtcAudioTrack: RTCAudioTrack?
    var rtcVideoTrack: RTCVideoTrack?
    var elementViewFrame: CGRect!

    init(
        webView: WKWebView,
        eventListener: @escaping (_ data: NSDictionary) -> Void
    ) {
        NSLog("PluginMediaStreamRenderer#init()")

        // Open Renderer
        self.id = UUID().uuidString
        self.closed = false

        // The browser HTML view.
        self.webView = webView
        self.eventListener = eventListener

        // The video element view.
        self.elementView = UIView()

        // The effective video view in which the the video stream is shown.
        // It's placed over the elementView.
        self.videoView = RTCEAGLVideoView()
        self.videoView.isUserInteractionEnabled = false

        self.elementView.isUserInteractionEnabled = false
        self.elementView.isHidden = true
        self.elementView.backgroundColor = UIColor.black
        self.elementView.addSubview(self.videoView)
        self.elementView.layer.masksToBounds = true

        // Place the video element view inside the WebView's superview
        self.webView.addSubview(self.elementView)
    }

    deinit {
        NSLog("PluginMediaStreamRenderer#deinit()")
    }

    func run() {
        NSLog("PluginMediaStreamRenderer#run()")

        self.videoView.delegate = self
        self.webView.scrollView.delegate = self
    }

    func render(_ pluginMediaStream: PluginMediaStream) {
        NSLog("PluginMediaStreamRenderer#render()")

        if self.pluginMediaStream != nil {
            self.reset()
        }

        self.pluginMediaStream = pluginMediaStream

        // Take the first audio track.
        for (_, track) in pluginMediaStream.audioTracks {
            self.rtcAudioTrack = track.rtcMediaStreamTrack as? RTCAudioTrack
            break
        }

        // Take the first video track.
        var pluginVideoTrack: PluginMediaStreamTrack?
        for (_, track) in pluginMediaStream.videoTracks {
            pluginVideoTrack = track
            self.rtcVideoTrack = track.rtcMediaStreamTrack as? RTCVideoTrack
            break
        }

        if self.rtcVideoTrack != nil {
            self.rtcVideoTrack!.add(self.videoView)
            pluginVideoTrack?.registerRender(render: self)
        }
    }

    func mediaStreamChanged() {
        NSLog("PluginMediaStreamRenderer#mediaStreamChanged()")

        if self.pluginMediaStream == nil {
            return
        }

        let oldRtcVideoTrack: RTCVideoTrack? = self.rtcVideoTrack

        self.rtcAudioTrack = nil
        self.rtcVideoTrack = nil

        // Take the first audio track.
        for (_, track) in self.pluginMediaStream!.audioTracks {
            self.rtcAudioTrack = track.rtcMediaStreamTrack as? RTCAudioTrack
            break
        }

        // Take the first video track.
        for (_, track) in pluginMediaStream!.videoTracks {
            self.rtcVideoTrack = track.rtcMediaStreamTrack as? RTCVideoTrack
            break
        }

        // If same video track as before do nothing.
        if oldRtcVideoTrack != nil && self.rtcVideoTrack != nil &&
            oldRtcVideoTrack!.trackId == self.rtcVideoTrack!.trackId {
            NSLog("PluginMediaStreamRenderer#mediaStreamChanged() | same video track as before")
        }

        // Different video track.
        else if oldRtcVideoTrack != nil && self.rtcVideoTrack != nil &&
            oldRtcVideoTrack!.trackId != self.rtcVideoTrack!.trackId {
            NSLog("PluginMediaStreamRenderer#mediaStreamChanged() | has a new video track")

            oldRtcVideoTrack!.remove(self.videoView)
            self.rtcVideoTrack!.add(self.videoView)
        }

        // Did not have video but now it has.
        else if oldRtcVideoTrack == nil && self.rtcVideoTrack != nil {
            NSLog("PluginMediaStreamRenderer#mediaStreamChanged() | video track added")

            self.rtcVideoTrack!.add(self.videoView)
        }

        // Had video but now it has not.
        else if oldRtcVideoTrack != nil && self.rtcVideoTrack == nil {
            NSLog("PluginMediaStreamRenderer#mediaStreamChanged() | video track removed")

            oldRtcVideoTrack!.remove(self.videoView)
        }
    }

    func refresh(_ data: NSDictionary) {

        let elementLeft = data.object(forKey: "elementLeft") as? Double ?? 0
        let elementTop = data.object(forKey: "elementTop") as? Double ?? 0
        let elementWidth = data.object(forKey: "elementWidth") as? Double ?? 0
        let elementHeight = data.object(forKey: "elementHeight") as? Double ?? 0
        var videoViewWidth = data.object(forKey: "videoViewWidth") as? Double ?? 0
        var videoViewHeight = data.object(forKey: "videoViewHeight") as? Double ?? 0
        let visible = data.object(forKey: "visible") as? Bool ?? true
        let opacity = data.object(forKey: "opacity") as? Double ?? 1
        let zIndex = data.object(forKey: "zIndex") as? Double ?? 0
        let mirrored = data.object(forKey: "mirrored") as? Bool ?? false
        let clip = data.object(forKey: "clip") as? Bool ?? true
        let borderRadius = data.object(forKey: "borderRadius") as? Double ?? 0

        NSLog("PluginMediaStreamRenderer#refresh() [elementLeft:%@, elementTop:%@, elementWidth:%@, elementHeight:%@, videoViewWidth:%@, videoViewHeight:%@, visible:%@, opacity:%@, zIndex:%@, mirrored:%@, clip:%@, borderRadius:%@]",
            String(elementLeft), String(elementTop), String(elementWidth), String(elementHeight),
            String(videoViewWidth), String(videoViewHeight), String(visible), String(opacity), String(zIndex),
            String(mirrored), String(clip), String(borderRadius))

        let videoViewLeft: Double = (elementWidth - videoViewWidth) / 2
        let videoViewTop: Double = (elementHeight - videoViewHeight) / 2

        self.elementViewFrame = CGRect(
            x: CGFloat(elementLeft),
            y: CGFloat(elementTop),
            width: CGFloat(elementWidth),
            height: CGFloat(elementHeight)
        )
        self.elementView.frame = self.elementViewFrame

        // NOTE: Avoid a zero-size UIView for the video (the library complains).
        if videoViewWidth == 0 || videoViewHeight == 0 {
            videoViewWidth = 1
            videoViewHeight = 1
            self.videoView.isHidden = true
        } else {
            self.videoView.isHidden = false
        }

        self.videoView.frame = CGRect(
            x: CGFloat(videoViewLeft),
            y: CGFloat(videoViewTop),
            width: CGFloat(videoViewWidth),
            height: CGFloat(videoViewHeight)
        )

        if visible {
            self.elementView.isHidden = false
        } else {
            self.elementView.isHidden = true
        }

        self.elementView.alpha = CGFloat(opacity)
        self.elementView.layer.zPosition = CGFloat(zIndex)

        // if the zIndex is 0 (the default) bring the view to the top, last one wins
        if zIndex == 0 {
            self.webView.bringSubviewToFront(self.elementView)
            //self.webView?.bringSubview(toFront: self.elementView)
        }

        if !mirrored {
            self.elementView.transform = CGAffineTransform.identity
        } else {
            self.elementView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }

        if clip {
            self.elementView.clipsToBounds = true
        } else {
            self.elementView.clipsToBounds = false
        }

        self.elementView.layer.cornerRadius = CGFloat(borderRadius)
    }

    func save() -> String {
        NSLog("PluginMediaStreamRenderer#save()")
        UIGraphicsBeginImageContextWithOptions(elementView.bounds.size, elementView.isOpaque, 0.0)
        elementView.drawHierarchy(in: elementView.bounds, afterScreenUpdates: false)
        let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageData = snapshotImageFromMyView?.jpegData(compressionQuality: 1.0)
        let strBase64 = imageData?.base64EncodedString(options: .lineLength64Characters)
        let imageDataPrefix = "data:image/jpeg;base64,"
        return imageDataPrefix + strBase64!
    }

    func stop() {
        NSLog("PluginMediaStreamRenderer | video stop")

        self.eventListener([
            "type": "videostop"
        ])
    }

    func close() {
        NSLog("PluginMediaStreamRenderer#close()")
        self.closed = true
        self.reset()
        self.elementView.removeFromSuperview()
    }

    /**
     * Private API.
     */

    fileprivate func reset() {
        NSLog("PluginMediaStreamRenderer#reset()")

        if self.rtcVideoTrack != nil {
            self.rtcVideoTrack!.remove(self.videoView)
        }

        self.pluginMediaStream = nil
        self.rtcAudioTrack = nil
        self.rtcVideoTrack = nil
    }

    /**
     * Methods inherited from RTCVideoViewDelegate.
     */

    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {

        NSLog("PluginMediaStreamRenderer | video size changed [width:%@, height:%@]",
            String(describing: size.width), String(describing: size.height))

        self.eventListener([
            "type": "videoresize",
            "size": [
                "width": Int(size.width),
                "height": Int(size.height)
            ]
        ])
    }
}

extension PluginMediaStreamRenderer: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let elementViewFrame = self.elementViewFrame {
            elementView.frame.origin.y = elementViewFrame.minY - scrollView.contentOffset.y
        }
    }

}

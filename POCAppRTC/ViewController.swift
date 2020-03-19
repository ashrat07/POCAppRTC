//
//  ViewController.swift
//  POCAppRTC
//
//  Created by Ashish Rathore on 19/02/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import UIKit
import WebKit
import AVKit
import JavaScriptCore
import SafariServices

class ViewController: UIViewController {

    struct Constants {
//        static let url = "https://www.google.com"
        static let url = "https://webrtc.github.io/samples/src/content/getusermedia/gum/"
//        static let url = "https://www.webrtc-experiment.com/msr/video-recorder.html"

        static let jsFileExtension = "js"
//        static let pluginFileName = "cordova-plugin-iosrtc"
        static let cordovaPluginFileName = "cordova-plugin-iosrtc-fork"
        static let microsoftJSFileName = "MicrosoftTeams"
        static let microsoftJSWebModuleName = "JSWebModule"

        // MediaStream
        static let MEDIA_STREAM_TAG = "iosrtc:MediaStream"
        static let MEDIA_STREAM_INIT_TAG = "iosrtc:MediaStreamInit"
        static let MEDIA_STREAM_SET_LISTENER_TAG = "iosrtc:MediaStreamSetListener"
        static let MEDIA_STREAM_ADD_TRACK_TAG = "iosrtc:MediaStreamAddTrack"
        static let MEDIA_STREAM_REMOVE_TRACK_TAG = "iosrtc:MediaStreamRemoveTrack"
        static let MEDIA_STREAM_RELEASE_TAG = "iosrtc:MediaStreamRelease"

        // MediaStreamRenderer
        static let MEDIA_STREAM_RENDERER_TAG = "iosrtc:MediaStreamRenderer"
        static let MEDIA_STREAM_RENDERER_NEW_TAG = "iosrtc:MediaStreamRendererNew"
        static let MEDIA_STREAM_RENDERER_RENDER_TAG = "iosrtc:MediaStreamRendererRender"
        static let MEDIA_STREAM_RENDERER_STREAM_CHANGED_TAG = "iosrtc:MediaStreamRendererStreamChanged"
        static let MEDIA_STREAM_RENDERER_SAVE_TAG = "iosrtc:MediaStreamRendererSave"
        static let MEDIA_STREAM_RENDERER_REFRESH_TAG = "iosrtc:MediaStreamRendererRefresh"
        static let MEDIA_STREAM_RENDERER_CLOSE_TAG = "iosrtc:MediaStreamRendererClose"

        // MediaStreamTrack
        static let MEDIA_STREAM_TRACK_TAG = "iosrtc:MediaStreamTrack"
        static let MEDIA_STREAM_TRACK_SET_LISTENER_TAG = "iosrtc:MediaStreamTrackSetListener"
        static let MEDIA_STREAM_TRACK_SET_ENABLED_TAG = "iosrtc:MediaStreamTrackSetEnabled"
        static let MEDIA_STREAM_TRACK_STOP_TAG = "iosrtc:MediaStreamTrackStop"

        // RTCDTMFSender
        static let RTCDTMF_SENDER_TAG = "iosrtc:RTCDTMFSender"
        static let RTCDTMF_SENDER_ERROR_TAG = "iosrtc:RTCDTMFSender:ERROR"
        static let RTCDTMF_SENDER_CREATE_DTMF_SENDER_TAG = "iosrtc:RTCDTMFSenderCreateDTMFSender"
        static let RTCDTMF_SENDER_INSERT_DTMF_TAG = "iosrtc:RTCDTMFSenderInsertDTMF"

        // RTCDataChannel
        static let RTC_DATA_CHANNEL_TAG = "iosrtc:RTCDataChannel"
        static let RTC_DATA_CHANNEL_ERROR_TAG = "iosrtc:RTCDataChannel:ERROR"
        static let RTC_DATA_CHANNEL_CREATE_DATA_CHANNEL_TAG = "iosrtc:RTCDataChannelCreateDataChannel"
        static let RTC_DATA_CHANNEL_SET_LISTENER_TAG = "iosrtc:RTCDataChannelSetListener"
        static let RTC_DATA_CHANNEL_SEND_STRING_TAG = "iosrtc:RTCDataChannelSendString"
        static let RTC_DATA_CHANNEL_SEND_BINARY_TAG = "iosrtc:RTCDataChannelSendBinary"
        static let RTC_DATA_CHANNEL_CLOSE_TAG = "iosrtc:RTCDataChannelClose"

        // RTCPeerConnection
        static let RTC_PEER_CONNECTION_TAG = "iosrtc:RTCPeerConnection"
        static let RTC_PEER_CONNECTION_ERROR_TAG = "iosrtc:RTCPeerConnection:ERROR"
        static let RTC_PEER_CONNECTION_NEW_TAG = "iosrtc:RTCPeerConnectionNew"
        static let RTC_PEER_CONNECTION_CREATE_OFFER_TAG = "iosrtc:RTCPeerConnectionCreateOffer"
        static let RTC_PEER_CONNECTION_CREATE_ANSWER_TAG = "iosrtc:RTCPeerConnectionCreateAnswer"
        static let RTC_PEER_CONNECTION_SET_LOCAL_DESCRIPTION_TAG = "iosrtc:RTCPeerConnectionSetLocalDescription"
        static let RTC_PEER_CONNECTION_SET_REMOTE_DESCRIPTION_TAG = "iosrtc:RTCPeerConnectionSetRemoteDescription"
        static let RTC_PEER_CONNECTION_ADD_ICE_CANDIDATE_TAG = "iosrtc:RTCPeerConnectionAddIceCandidate"
        static let RTC_PEER_CONNECTION_ADD_STREAM_TAG = "iosrtc:RTCPeerConnectionAddStream"
        static let RTC_PEER_CONNECTION_REMOVE_STREAM_TAG = "iosrtc:RTCPeerConnectionRemoveStream"
        static let RTC_PEER_CONNECTION_ADD_TRACK_TAG = "iosrtc:RTCPeerConnectionAddTrack"
        static let RTC_PEER_CONNECTION_REMOVE_TRACK_TAG = "iosrtc:RTCPeerConnectionRemoveTrack"
        static let RTC_PEER_CONNECTION_GET_STATS_TAG = "iosrtc:RTCPeerConnectionGetStats"
        static let RTC_PEER_CONNECTION_CLOSE_TAG = "iosrtc:RTCPeerConnectionClose"

        // enumerateDevices
        static let ENUM_DEVICES_TAG = "iosrtc:enumerateDevices"

        // getUserMedia
        static let GET_USER_MEDIA_TAG = "iosrtc:getUserMedia"
        static let GET_USER_MEDIA_ERROR_TAG = "iosrtc:getUserMedia:ERROR"

        // Variables
        static let SETUP_SELECT_AUDIO_OUTPUT_EARPIECE_TAG = "iosrtc:selectAudioOutputEarpiece"
        static let SETUP_SELECT_AUDIO_OUTPUT_SPEAKER_TAG = "iosrtc:selectAudioOutputSpeaker"
        static let SETUP_RTC_TURN_ON_SPEAKER_TAG = "iosrtc:RTCTurnOnSpeaker"
        static let SETUP_RTC_REQUEST_PERMISSION_TAG = "iosrtc:RTCRequestPermission"
        static let SETUP_DUMP_TAG = "iosrtc:dump"
    }

    var cameraPermissionButton: UIButton!
    let configuration = WKWebViewConfiguration()
    let contentController = WKUserContentController()
    var webView: WKWebView!
    var stream: RTCMediaStream!
    var count = 0

    // RTCPeerConnectionFactory single instance.
    var rtcPeerConnectionFactory: RTCPeerConnectionFactory!
    // Single PluginGetUserMedia instance.
    var pluginGetUserMedia: PluginGetUserMedia!
    // PluginRTCPeerConnection dictionary.
    var pluginRTCPeerConnections: [Int : PluginRTCPeerConnection]!
    // PluginMediaStream dictionary.
    var pluginMediaStreams: [String : PluginMediaStream]!
    // PluginMediaStreamTrack dictionary.
    var pluginMediaStreamTracks: [String : PluginMediaStreamTrack]!
    // PluginMediaStreamRenderer dictionary.
    var pluginMediaStreamRenderers: [Int : PluginMediaStreamRenderer]!
    // Dispatch queue for serial operations.
    var queue: DispatchQueue!
    // Auto selecting output speaker
    var audioOutputController: PluginRTCAudioController!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reloadPage))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Push", style: .plain, target: self, action: #selector(push))

//        let preferences = WKPreferences()
//        configuration.preferences = preferences
//        WKPreferencesSetMediaDevicesEnabled(configuration.preferences, true)

        createContentController()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self

        loadPage()

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        cameraPermissionButton = UIButton(type: .system)
        cameraPermissionButton.setTitle("Grant Camera Permission", for: .normal)
        cameraPermissionButton.addTarget(self, action: #selector(askCameraPermissionIfNeeded), for: .touchUpInside)
        view.addSubview(cameraPermissionButton)
        cameraPermissionButton.translatesAutoresizingMaskIntoConstraints = false
        cameraPermissionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cameraPermissionButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCameraPermissionButton()

        default:
            showWebView()
        }

        pluginInitialize()
    }

    @objc func askCameraPermissionIfNeeded() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            self.showCameraPermissionButton()
            self.setupCaptureSession()

        case .notDetermined:
            // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.showCameraPermissionButton()
                        self.setupCaptureSession()
                    }
                }
            }

        case .denied:
            // The user has previously denied access.
            return

        case .restricted:
            // The user can't grant access due to restrictions.
            return
        @unknown default:
            return
        }
    }

    func showCameraPermissionButton() {
        webView.isHidden = false
        cameraPermissionButton.isHidden = true
    }

    func showWebView() {
        webView.isHidden = true
        cameraPermissionButton.isHidden = false
    }

    func setupCaptureSession() {

    }

    @objc func loadPage() {
        guard let url = URL(string: Constants.url) else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    @objc func reloadPage() {
        webView.reload()
    }

    @objc func push() {
        let viewController = WebViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

//    @objc func push() {
//        guard let url = URL(string: Constants.url) else {
//            return
//        }
//        let configuration = SFSafariViewController.Configuration()
//        configuration.barCollapsingEnabled = true
//        let viewController = SFSafariViewController(url: url, configuration: configuration)
//        present(viewController, animated: true)
//    }

    func createContentController() {
        if let script = generateAddCSSScript() {
          contentController.addUserScript(script)
        }

        let jsFiles = [
            "script",
            Constants.cordovaPluginFileName,
            Constants.microsoftJSWebModuleName,
            Constants.microsoftJSFileName,
        ]
        for jsFile in jsFiles {
            if let script = getUserScript(jsFile, fileExtension: Constants.jsFileExtension) {
                contentController.addUserScript(script)
            }
        }

        contentController.add(self, name: "count")
        contentController.add(self, name: "listener")
        configuration.userContentController = contentController
    }

    func generateAddCSSScript() -> WKUserScript? {
      guard let cssPath = Bundle.main.path(forResource: "style", ofType: "css"),
      let cssString = try? String(contentsOfFile: cssPath).components(separatedBy: .newlines).joined() else {
        return nil
      }

      let source = """
      var style = document.createElement('style');
      style.innerHTML = '\(cssString)';
      document.head.appendChild(style);
      """

      let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
      return script
    }

    func getUserScript(_ fileName: String, fileExtension: String) -> WKUserScript? {
        guard let scriptPath = Bundle.main.path(forResource: fileName, ofType: fileExtension),
            let scriptSource = try? String(contentsOfFile: scriptPath) else {
                return nil
        }

        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        return script
    }

//    func establishPeerConnection() {
//        let configuration = RTCConfiguration()
//        let factory = RTCPeerConnectionFactory()
//        let constraints = [
//            kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
//            kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue
//        ]
//        let mediaConstraints = RTCMediaConstraints(mandatoryConstraints: constraints, optionalConstraints: nil)
//        let peerConnection = factory.peerConnection(with: configuration, constraints: mediaConstraints, delegate: self)
//
//        let streamId = UUID().uuidString
//        stream = factory.mediaStream(withStreamId: streamId) // "audioVideo"
//        let audioTrackId = UUID().uuidString
//        let audioTrack = factory.audioTrack(with: factory.audioSource(with: mediaConstraints), trackId: audioTrackId) // "audio"
//        let videoTrackId = UUID().uuidString
//        let videoTrack = factory.videoTrack(with: factory.videoSource(), trackId: videoTrackId) // "video"
//        stream.addAudioTrack(audioTrack)
//        stream.addVideoTrack(videoTrack)
//
//        print("")
//        createOffer(peerConnection, mediaConstraints)
//    }
//
//    func createOffer(_ peerConnection: RTCPeerConnection, _ mediaConstraints: RTCMediaConstraints) {
//        peerConnection.offer(for: mediaConstraints) { sdp, error in
//            guard let sdp = sdp else {
//                print(error)
//                return
//            }
//            print("sdp: \(sdp)")
//
//            self.setLocalDescription(peerConnection, sdp)
//        }
//    }
//
//    func setLocalDescription(_ peerConnection: RTCPeerConnection, _ sdp: RTCSessionDescription) {
//        peerConnection.setLocalDescription(sdp) { error in
//            DispatchQueue.main.async {
//                let object: [String: String] = [
//                    "sdp": sdp.sdp,
//                    "type": RTCSessionDescription.string(for: .offer)
//                ]
//                guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
//                    let value = String(data: data, encoding: String.Encoding.ascii) else {
//                        return
//                }
//                let javaScriptString = "RTCPeerConnection(\(value))"
//                self.webView.evaluateJavaScript(javaScriptString) { data, error in
//                    print("data: \(data), error: \(error)")
//                }
//            }
//        }
//    }

    func doSomething() {
        let pcConfig: [String: Any] = [
            kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue,
            kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
            "iceServers": [
                [
                    "url": "stun:stun.stunprotocol.org"
                ]
            ]
        ]
        let configuration = RTCConfiguration()
        configuration.shouldPruneTurnPorts = true
        configuration.candidateNetworkPolicy = RTCCandidateNetworkPolicy.all
        configuration.tcpCandidatePolicy = .enabled
        configuration.iceTransportPolicy = .relay
        let constraints = [
            kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue,
            kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue
        ]
        let mediaConstraints = RTCMediaConstraints(mandatoryConstraints: constraints, optionalConstraints: nil)
        let factory = RTCPeerConnectionFactory()
        let pc1 = factory.peerConnection(with: configuration, constraints: mediaConstraints, delegate: self)
        let pc2 = factory.peerConnection(with: configuration, constraints: mediaConstraints, delegate: self)

//        let streamId = UUID().uuidString
        stream = factory.mediaStream(withStreamId: "audioVideo")
//        let audioTrackId = UUID().uuidString
        let audioTrack = factory.audioTrack(with: factory.audioSource(with: mediaConstraints), trackId: "audio")
//        let videoTrackId = UUID().uuidString
        let videoTrack = factory.videoTrack(with: factory.videoSource(), trackId: "video")
        let sender1 = pc1.add(audioTrack, streamIds: ["audio"])
        let sender2 = pc1.add(videoTrack, streamIds: ["video"])

        stream.addAudioTrack(audioTrack)
        stream.addVideoTrack(videoTrack)

//        stream.

        createOffer(pc1, mediaConstraints)
    }

    func createOffer(_ peerConnection: RTCPeerConnection, _ mediaConstraints: RTCMediaConstraints) {
        peerConnection.offer(for: mediaConstraints) { sdp, error in
            guard let sdp = sdp else {
                print(error)
                return
            }
            print("sdp: \(sdp)")

            self.setLocalDescription(peerConnection, sdp)
        }
    }

    func setLocalDescription(_ peerConnection: RTCPeerConnection, _ sdp: RTCSessionDescription) {
        peerConnection.setLocalDescription(sdp) { error in
            DispatchQueue.main.async {
                let object: [String: String] = [
                    "sdp": sdp.sdp,
                    "type": RTCSessionDescription.string(for: .offer)
                ]
                guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
                    let value = String(data: data, encoding: String.Encoding.ascii) else {
                        return
                }
                let javaScriptString = "RTCPeerConnection(\(value))"
                self.webView.evaluateJavaScript(javaScriptString) { data, error in
                    print("data: \(data), error: \(error)")
                }
            }
        }
    }

}

extension ViewController: WKUIDelegate {

}

extension ViewController: WKNavigationDelegate {

}

extension ViewController: UIWebViewDelegate {

}

extension ViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "count", let messageBody = message.body as? String {
            print(messageBody)
            count += 1
            let javascript = "document.getElementById(\"countLabel\").innerHTML = \"Count: \(count)\";"
            webView.evaluateJavaScript(javascript, completionHandler: nil)
        }
        else if message.name == "listener" {
            print("body: \(message.body)")

            if let body = message.body as? NSDictionary,
                let event = body["event"] as? String,
                let requestId = body["requestId"] as? Int {

                let resource = body["resource"] as? [Any] ?? []
                guard let command = CDVInvokedUrlCommand(arguments: resource, callbackId: "\(requestId)", className: nil, methodName: nil) else {
                    return
                }

                // MediaStream
                if event == Constants.MEDIA_STREAM_TAG {
                    print("❗️❗️❗️❗️❗️ event: \(event) ❗️❗️❗️❗️❗️")
                }
                else if event == Constants.MEDIA_STREAM_INIT_TAG {
                    MediaStream_init(command)
                }
                else if event == Constants.MEDIA_STREAM_SET_LISTENER_TAG {
                    MediaStream_setListener(command)
                }
                else if event == Constants.MEDIA_STREAM_ADD_TRACK_TAG {
                    MediaStream_addTrack(command)
                }
                else if event == Constants.MEDIA_STREAM_REMOVE_TRACK_TAG {
                    MediaStream_addTrack(command)
                }
                else if event == Constants.MEDIA_STREAM_RELEASE_TAG {
                    MediaStream_release(command)
                }

                // MediaStreamRenderer
                else if event == Constants.MEDIA_STREAM_RENDERER_TAG {
                    print("❗️❗️❗️❗️❗️ event: \(event) ❗️❗️❗️❗️❗️")
                }
                else if event == Constants.MEDIA_STREAM_RENDERER_NEW_TAG {
                    new_MediaStreamRenderer(command)
                }
                else if event == Constants.MEDIA_STREAM_RENDERER_RENDER_TAG {
                    MediaStreamRenderer_render(command)
                }
                else if event == Constants.MEDIA_STREAM_RENDERER_STREAM_CHANGED_TAG {
                    MediaStreamRenderer_mediaStreamChanged(command)
                }
                else if event == Constants.MEDIA_STREAM_RENDERER_SAVE_TAG {
                    MediaStreamRenderer_save(command)
                }
                else if event == Constants.MEDIA_STREAM_RENDERER_REFRESH_TAG {
                    MediaStreamRenderer_refresh(command)
                }
                else if event == Constants.MEDIA_STREAM_RENDERER_CLOSE_TAG {
                    MediaStreamRenderer_close(command)
                }

                // MediaStreamTrack
                else if event == Constants.MEDIA_STREAM_TRACK_TAG {
                    print("❗️❗️❗️❗️❗️ event: \(event) ❗️❗️❗️❗️❗️")
                }
                else if event == Constants.MEDIA_STREAM_TRACK_SET_LISTENER_TAG {
                    MediaStreamTrack_setListener(command)
                }
                else if event == Constants.MEDIA_STREAM_TRACK_SET_ENABLED_TAG {
                    MediaStreamTrack_setEnabled(command)
                }
                else if event == Constants.MEDIA_STREAM_TRACK_STOP_TAG {
                    MediaStreamTrack_stop(command)
                }

                // RTCDTMFSender
                else if event == Constants.RTCDTMF_SENDER_TAG {
                    print("❗️❗️❗️❗️❗️ event: \(event) ❗️❗️❗️❗️❗️")
                }
                else if event == Constants.RTCDTMF_SENDER_ERROR_TAG {
                    print("❗️❗️❗️❗️❗️ event: \(event) ❗️❗️❗️❗️❗️")
                }
                else if event == Constants.RTCDTMF_SENDER_CREATE_DTMF_SENDER_TAG {
                    RTCPeerConnection_createDTMFSender(command)
                }
                else if event == Constants.RTCDTMF_SENDER_INSERT_DTMF_TAG {
                    RTCPeerConnection_RTCDTMFSender_insertDTMF(command)
                }

                // RTCDataChannel
                else if event == Constants.RTC_DATA_CHANNEL_TAG {
                    print("❗️❗️❗️❗️❗️ event: \(event) ❗️❗️❗️❗️❗️")
                }
                else if event == Constants.RTC_DATA_CHANNEL_ERROR_TAG {
                    print("❗️❗️❗️❗️❗️ event: \(event) ❗️❗️❗️❗️❗️")
                }
                else if event == Constants.RTC_DATA_CHANNEL_CREATE_DATA_CHANNEL_TAG {
                    RTCPeerConnection_createDataChannel(command)
                }
                else if event == Constants.RTC_DATA_CHANNEL_SET_LISTENER_TAG {
                    RTCPeerConnection_RTCDataChannel_setListener(command)
                }
                else if event == Constants.RTC_DATA_CHANNEL_SEND_STRING_TAG {
                    RTCPeerConnection_RTCDataChannel_sendString(command)
                }
                else if event == Constants.RTC_DATA_CHANNEL_SEND_BINARY_TAG {
                    RTCPeerConnection_RTCDataChannel_sendBinary(command)
                }
                else if event == Constants.RTC_DATA_CHANNEL_CLOSE_TAG {
                    RTCPeerConnection_RTCDataChannel_close(command)
                }

                // RTCPeerConnection
                else if event == Constants.RTC_PEER_CONNECTION_TAG {
                    print("❗️❗️❗️❗️❗️ event: \(event) ❗️❗️❗️❗️❗️")
                }
                else if event == Constants.RTC_PEER_CONNECTION_ERROR_TAG {
                    print("❗️❗️❗️❗️❗️ event: \(event) ❗️❗️❗️❗️❗️")
                }
                else if event == Constants.RTC_PEER_CONNECTION_NEW_TAG {
                    new_RTCPeerConnection(command)
                }
                else if event == Constants.RTC_PEER_CONNECTION_CREATE_OFFER_TAG {
                    RTCPeerConnection_createOffer(command)
                }
                else if event == Constants.RTC_PEER_CONNECTION_CREATE_ANSWER_TAG {
                    RTCPeerConnection_createAnswer(command)
                }
                else if event == Constants.RTC_PEER_CONNECTION_SET_LOCAL_DESCRIPTION_TAG {
                    RTCPeerConnection_setLocalDescription(command)
                }
                else if event == Constants.RTC_PEER_CONNECTION_SET_REMOTE_DESCRIPTION_TAG {
                    RTCPeerConnection_setRemoteDescription(command)
                }
                else if event == Constants.RTC_PEER_CONNECTION_ADD_ICE_CANDIDATE_TAG {
                    RTCPeerConnection_addIceCandidate(command)
                }
                else if event == Constants.RTC_PEER_CONNECTION_ADD_STREAM_TAG {
                    RTCPeerConnection_addStream(command)
                }
                else if event == Constants.RTC_PEER_CONNECTION_REMOVE_STREAM_TAG {
                    RTCPeerConnection_removeStream(command)
                }
                else if event == Constants.RTC_PEER_CONNECTION_ADD_TRACK_TAG {
                    RTCPeerConnection_addTrack(command)
                }
                else if event == Constants.RTC_PEER_CONNECTION_REMOVE_TRACK_TAG {
                    RTCPeerConnection_removeTrack(command)
                }
                else if event == Constants.RTC_PEER_CONNECTION_GET_STATS_TAG {
                    RTCPeerConnection_getStats(command)
                }
                else if event == Constants.RTC_PEER_CONNECTION_CLOSE_TAG {
                    RTCPeerConnection_close(command)
                }

                // enumerateDevices
                else if event == Constants.ENUM_DEVICES_TAG {
                    enumerateDevices(command)
                }

                // getUserMedia
                else if event == Constants.GET_USER_MEDIA_TAG {
                    getUserMedia(command)
                }
                else if event == Constants.GET_USER_MEDIA_ERROR_TAG {
                    print("❗️❗️❗️❗️❗️ event: \(event) ❗️❗️❗️❗️❗️")
                }

                // Variables
                else if event == Constants.SETUP_SELECT_AUDIO_OUTPUT_EARPIECE_TAG {
                    selectAudioOutputEarpiece(command)
                }
                else if event == Constants.SETUP_SELECT_AUDIO_OUTPUT_SPEAKER_TAG {
                    selectAudioOutputSpeaker(command)
                }
                else if event == Constants.SETUP_RTC_TURN_ON_SPEAKER_TAG {
                    RTCTurnOnSpeaker(command)
                }
                else if event == Constants.SETUP_RTC_REQUEST_PERMISSION_TAG {
                    RTCRequestPermission(command)
                }
                else if event == Constants.SETUP_DUMP_TAG {
                    dump(command)
                }
                else {
                    print("❗️❗️❗️❗️❗️ event: \(event) ❗️❗️❗️❗️❗️")
                }
            }
        }
    }

}

extension ViewController: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("\(#function): \(stateChanged)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("\(#function): \(stream)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("\(#function): \(stream)")
    }

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("\(#function)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("\(#function): \(newState)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("\(#function): \(newState)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print("\(#function): \(candidate)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("\(#function): \(candidates)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("\(#function): \(dataChannel)")
    }
}

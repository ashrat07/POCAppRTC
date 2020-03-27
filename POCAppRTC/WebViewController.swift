//
//  WebViewController.swift
//  POCAppRTC
//
//  Created by Ashish Rathore on 19/02/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import UIKit
import WebKit
import AVKit

class WebViewController: UIViewController {

    struct Constants {
//        static let url = "https://appr.tc/"
//        static let url = "https://webrtc.github.io/samples/src/content/getusermedia/gum/"
//        static let url = "https://www.webrtc-experiment.com/msr/video-recorder.html"
//        static let url = "https://webrtc.github.io/samples/src/content/peerconnection/pc1/"
        static let url = "https://webrtc.github.io/samples/src/content/getusermedia/canvas/"
//        static let url = "https://webrtc.github.io/samples/src/content/getusermedia/record/"

        static let jsFileExtension = "js"
        static let cordovaPluginFileName = "cordova-plugin-iosrtc"
        static let microsoftJSFileName = "MicrosoftTeams"
        static let microsoftJSWebModuleName = "JSWebModule"
        static let scriptMessageHandlerName = "listener"

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

    let configuration = WKWebViewConfiguration()
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

        createContentController()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        loadPage()
        pluginInitialize()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        configuration.userContentController.removeScriptMessageHandler(forName: Constants.scriptMessageHandlerName)
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

    func createContentController() {
        let contentController = WKUserContentController()
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
        contentController.add(self, name: Constants.scriptMessageHandlerName)
        configuration.userContentController = contentController
    }

    func getUserScript(_ fileName: String, fileExtension: String) -> WKUserScript? {
        guard let scriptPath = Bundle.main.path(forResource: fileName, ofType: fileExtension),
            let scriptSource = try? String(contentsOfFile: scriptPath) else {
                return nil
        }

        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        return script
    }
}

extension WebViewController: WKUIDelegate {

}

extension WebViewController: WKNavigationDelegate {

}

extension WebViewController: UIWebViewDelegate {

}

extension WebViewController: WKScriptMessageHandler {

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

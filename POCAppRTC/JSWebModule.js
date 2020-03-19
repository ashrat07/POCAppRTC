//
//  JSWebModule.js
//  TeamSpaceApp
//
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

// Custom namespace where all the bridging functionality resides
window.teams = window.teams || {};
window.teams.messageHandlers = window.teams.messageHandlers || {};

window.nativeInterface = {
    callbacks : {},
    handlers: {},

    logType : {
        LogInfo : 1,
        LogError : 2,
        LogWarning : 3
    },

    localHandlerMap : {
        'setUpViews' : 'setModuleView',
        'setNavBarMenu' : 'navBarMenuItemPress',
        'showActionMenu' : 'actionMenuItemPress',
    },

    setupBackButtonHandler: function() {
        this.handlers["backButtonPress"] = function() {
            this.log("JSWebModule: backButtonPress handler called", this.logType.LogInfo);
            this.postSdkResponseWithFunc(window, "backButtonPress", null);
        }
    },

    setupSaveSettingsHandler: function() {
        this.handlers["settings.save"] = function() {
            this.log("JSWebModule: settings.save handler called", this.logType.LogInfo);
            this.postSdkResponseWithFunc(window, "settings.save", null);
        }
    },

    setupRemoveSettingsHandler: function() {
        this.handlers["settings.remove"] = function() {
            this.log("JSWebModule: settings.remove handler called", this.logType.LogInfo);
            this.postSdkResponseWithFunc(window, "settings.remove", null);
        }
    },

    // API to fake window message handle for old hosting
    postMessage: function (event) {
        if (!event) {
            this.log("Invalid event", this.logType.LogError);
        }

        var sourceWindow = window;
        var request = new this.sdkRequest(event.id, event.func, event.args);
        this.processMessageRequest(sourceWindow, request);
    },

    // API to window message handle for old hosting
    postWindowMessage: function (event) {
        if (!event || !event.data ) {
            this.log("Invalid event", this.logType.LogError);
        }
        var request = new this.sdkRequest(event.data.id, event.data.func, event.data.args);
        this.processMessageRequest(event.source, request);
    },

    // API to window message handle
    framelessPostMessage: function (event) {
        this.postMessage(JSON.parse(event));
    },

    // MessageRequest object processing API
    processMessageRequest: function (sourceWindow, request) {
        // Uncomment to debug log the request object
        // this.debugLog(request);

        if (!this.isValidSdkRequest(request)) {
            return;
        }

        if (request.func === 'initialize') {

            this.log("JSWebModule: initialize event received", this.logType.LogInfo);
            this.callbacks[request.id] = function(frameContext) {
                this.postSdkResponseWithId(sourceWindow, request.id, [frameContext, "ios"]);
            }
            webkit.messageHandlers.listener.postMessage({ "event" : request.func, "requestId" : request.id });

        } else if (request.func === 'getContext') {

            this.log("JSWebModule: getContext event received", this.logType.LogInfo);
            this.callbacks[request.id] = function(encodedContext) {
                this.log("JSWebModule: getContext callback called", this.logType.LogInfo);
                if (typeof encodedContext === 'string') {
                    var decodedContext = window.atob(encodedContext);
                    var context = JSON.parse(decodedContext);
                    this.postSdkResponseWithId(sourceWindow, request.id, [context]);
                } else {
                    this.log("JSWebModule: Failed to get context", this.logType.LogWarning);
                }
            }
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id });

        } else if (request.func === 'authentication.authenticate.success') {

            this.log("JSWebModule: authentication.authenticate.success event received",  this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func === 'authentication.authenticate.failure') {

            this.log("JSWebModule: authentication.authenticate.failure event received",  this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func === 'authentication.authenticate') {

            this.log("JSWebModule: authentication.authenticate event received",  this.logType.LogInfo);
            this.callbacks[request.id] = function(encodedResult) {
                this.log("JSWebModule: authentication.authenticate callback called", this.logType.LogInfo);
                if (typeof encodedResult === 'string') {
                    var decodedResult = window.atob(encodedResult);
                    var result = JSON.parse(decodedResult);
                    if ('reason' in result) {
                        this.postSdkResponseWithId(sourceWindow, request.id, [false, result['reason']]);
                        this.log("JSWebModule: authentication.authenticate callback failure posted", this.logType.LogInfo);
                    } else if ('token' in result) {
                        this.postSdkResponseWithId(sourceWindow, request.id, [true, result['token']]);
                        this.log("JSWebModule: authentication.authenticate callback success posted", this.logType.LogInfo);
                    } else {
                        this.postSdkResponseWithId(sourceWindow, request.id, [true, result]);
                        this.log("JSWebModule: authentication.authenticate callback success posted", this.logType.LogInfo);
                    }
                }
            }
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func === 'authentication.getAuthToken') {

            this.log("JSWebModule: authentication.getAuthToken event received",  this.logType.LogInfo);

            var resource;
            if (request.args.length == 0 || !Array.isArray(request.args[0]) || request.args[0].length == 0 || typeof request.args[0][0] !== 'string') {
                resource = null;
            } else {
                resource = request.args[0][0];
            }

            this.callbacks[request.id] = function(token) {
                this.log("JSWebModule: get AuthToken callback called", this.logType.LogInfo);
                if (typeof token === 'string') {
                    if (token === 'ResourceError') {
                         this.log("JSWebModule: Failed to get auth token due to resource error",  this.logType.LogWarning);
                         this.postSdkResponseWithId(sourceWindow, request.id, [false, "Failed to get auth token due to resource error"]);
                    } else if (token === 'ADALError') {
                        this.log("JSWebModule: Failed to get auth token due to ADAL error",  this.logType.LogWarning);
                        this.postSdkResponseWithId(sourceWindow, request.id, [false, "Failed to get auth token due to ADAL error"]);
                    } else if (token === 'UserCancellationError') {
                        this.log("JSWebModule: Failed to get auth token due to user cancellation of consent flow",  this.logType.LogWarning);
                        this.postSdkResponseWithId(sourceWindow, request.id, [false, "Failed to get auth token due to user cancellation of consent flow"]);
                    } else {
                        this.log("JSWebModule: Fetched auth token successfully",  this.logType.LogInfo);
                        this.postSdkResponseWithId(sourceWindow, request.id, [true, token]);
                    }
                }
            }
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : resource });

        } else if (request.func === 'openFilePreview') {
            this.log("JSWebModule: openFilePreview event received", this.logType.LogInfo);

            let fileName = request.args[1];
            let fileType = request.args[3];
            let fileUrl = request.args[4];
            let fileDownloadUrl = request.args[5];
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "fileDownloadUrl" : fileDownloadUrl, "fileName" : fileName,  "fileType" : fileType,  "fileUrl" : fileUrl });
        } else if (request.func === 'setUpViews' || request.func == 'setNavBarMenu') {

            this.log("JSWebModule: "+ request.func + " event received", request.func, this.logType.LogInfo);

            this.addHandler(this.localHandlerMap[request.func], sourceWindow);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func, "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func == 'showActionMenu') {

            this.log("JSWebModule: "+ request.func + " event received", request.func, this.logType.LogInfo);

            this.addHandler(this.localHandlerMap[request.func], sourceWindow);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func, "requestId" : request.id, "actionMenuParams": request.args[0], "resource" : request.args[1] });

        } else if (request.func == 'handleNavBarMenuItemPress' || request.func == 'viewConfigItemPress' || request.func == 'handleActionMenuItemPress') {

            this.log("JSWebModule: "+ request.func + " event received", request.func, this.logType.LogInfo);

        } else if (request.func == 'tasks.startTask') {

            this.log("JSWebModule: startTask event received", this.logType.LogInfo);
            this.callbacks[request.id] = function(result) {
                var jsonObject = null;

                if (typeof result == 'object') {
                    jsonObject = json;
                }else {
                    try {
                        jsonObject = JSON.parse(result);
                    }
                    catch (e) {
                        jsonObject = '{}';
                    }
                }
                this.log("JSWebModule: startTask callback called", this.logType.LogInfo);
                this.postSdkResponseWithId(sourceWindow, request.id, [null, jsonObject]);
            }
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });
        } else if (request.func == 'tasks.submitTask') {

            this.log("JSWebModule: submitTask event received", this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func == 'tasks.completeTask') {

            this.log("JSWebModule: completeTask event received", this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func == 'navigateBack') {

            this.log("JSWebModule: navigateBack event received", this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func === 'settings.setValidityState') {

            this.log("JSWebModule: settings.setValidityState event received",  this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func === 'settings.getSettings') {

            this.log("JSWebModule: settings.getSettings event received",  this.logType.LogInfo);
            this.callbacks[request.id] = function(encodedSettings) {
                this.log("JSWebModule: settings.getSettings callback called", this.logType.LogInfo);
                if (typeof encodedSettings === 'string') {
                    var decodedSettings = window.atob(encodedSettings);
                    var settings = JSON.parse(decodedSettings);
                    this.postSdkResponseWithId(sourceWindow, request.id, [settings]);
                } else {
                    this.log("JSWebModule: Failed to get settings", this.logType.LogWarning);
                }
            }
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func === 'settings.setSettings') {

            this.log("JSWebModule: settings.setSettings event received",  this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func === 'settings.save.success') {

            this.log("JSWebModule: settings.save.success event received",  this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func === 'settings.save.failure') {

            this.log("JSWebModule: settings.save.failure event received",  this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func === 'settings.remove.success') {

            this.log("JSWebModule: settings.remove.success event received",  this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func === 'settings.remove.failure') {

            this.log("JSWebModule: settings.remove.failure event received",  this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func === 'navigateCrossDomain') {

            this.log("JSWebModule: navigateCrossDomain event received",  this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (request.func === 'executeDeepLink') {

            this.log("JSWebModule: executeDeepLink event received",  this.logType.LogInfo);
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args[0] });

        } else if (
                   // MediaStream
                   request.func == 'iosrtc:MediaStream' ||
                   request.func == 'iosrtc:MediaStreamInit' ||
                   request.func == 'iosrtc:MediaStreamSetListener' ||
                   request.func == 'iosrtc:MediaStreamAddTrack' ||
                   request.func == 'iosrtc:MediaStreamRemoveTrack' ||
                   request.func == 'iosrtc:MediaStreamRelease' ||
                   
                   // MediaStreamRenderer
                   request.func == 'iosrtc:MediaStreamRenderer' ||
                   request.func == 'iosrtc:MediaStreamRendererNew' ||
                   request.func == 'iosrtc:MediaStreamRendererRender' ||
                   request.func == 'iosrtc:MediaStreamRendererStreamChanged' ||
                   request.func == 'iosrtc:MediaStreamRendererSave' ||
                   request.func == 'iosrtc:MediaStreamRendererRefresh' ||
                   request.func == 'iosrtc:MediaStreamRendererClose' ||
                   
                   // MediaStreamTrack
                   request.func == 'iosrtc:MediaStreamTrack' ||
                   request.func == 'iosrtc:MediaStreamTrackSetListener' ||
                   request.func == 'iosrtc:MediaStreamTrackSetEnabled' ||
                   request.func == 'iosrtc:MediaStreamTrackStop' ||
                   
                   // RTCDTMFSender
                   request.func == 'iosrtc:RTCDTMFSender' ||
                   request.func == 'iosrtc:RTCDTMFSender:ERROR' ||
                   request.func == 'iosrtc:RTCDTMFSenderCreateDTMFSender' ||
                   request.func == 'iosrtc:RTCDTMFSenderInsertDTMF' ||
                   
                   // RTCDataChannel
                   request.func == 'iosrtc:RTCDataChannel' ||
                   request.func == 'iosrtc:RTCDataChannel:ERROR' ||
                   request.func == 'iosrtc:RTCDataChannelCreateDataChannel' ||
                   request.func == 'iosrtc:RTCDataChannelSetListener' ||
                   request.func == 'iosrtc:RTCDataChannelSendString' ||
                   request.func == 'iosrtc:RTCDataChannelSendBinary' ||
                   request.func == 'iosrtc:RTCDataChannelClose' ||
                   
                   // RTCPeerConnection
                   request.func == 'iosrtc:RTCPeerConnection' ||
                   request.func == 'iosrtc:RTCPeerConnection:ERROR' ||
                   request.func == 'iosrtc:RTCPeerConnectionNew' ||
                   request.func == 'iosrtc:RTCPeerConnectionCreateOffer' ||
                   request.func == 'iosrtc:RTCPeerConnectionCreateAnswer' ||
                   request.func == 'iosrtc:RTCPeerConnectionSetLocalDescription' ||
                   request.func == 'iosrtc:RTCPeerConnectionSetRemoteDescription' ||
                   request.func == 'iosrtc:RTCPeerConnectionAddIceCandidate' ||
                   request.func == 'iosrtc:RTCPeerConnectionAddStream' ||
                   request.func == 'iosrtc:RTCPeerConnectionRemoveStream' ||
                   request.func == 'iosrtc:RTCPeerConnectionAddTrack' ||
                   request.func == 'iosrtc:RTCPeerConnectionRemoveTrack' ||
                   request.func == 'iosrtc:RTCPeerConnectionGetStats' ||
                   request.func == 'iosrtc:RTCPeerConnectionClose' ||
                   
                   // enumerateDevices
                   request.func == 'iosrtc:enumerateDevices' ||
                   
                   // getUserMedia
                   request.func == 'iosrtc:getUserMedia' ||
                   request.func == 'iosrtc:getUserMedia:ERROR' ||
                   
                   // Variables
                   request.func == 'iosrtc:selectAudioOutputEarpiece' ||
                   request.func == 'iosrtc:selectAudioOutputSpeaker' ||
                   request.func == 'iosrtc:RTCTurnOnSpeaker' ||
                   request.func == 'iosrtc:RTCRequestPermission' ||
                   request.func == 'iosrtc:dump'
                   
                   ) {
            
//            this.log("JSWebModule: " + (request.func) + " event received", this.logType.LogInfo);
            this.callbacks[request.id] = function(response) {
                this.postSdkResponseWithId(sourceWindow, request.id, response);
            }
            webkit.messageHandlers.listener.postMessage({ "event" : request.func , "requestId" : request.id, "resource" : request.args });

        } else {
            this.log("JSWebModule: Unsupported event received", this.logType.LogInfo);
        }
    },

    addHandler: function(handlerName, sourceWindow) {
        this.handlers[handlerName] = function(id) {
            this.log("JSWebModule: handler called", this.logType.LogInfo);
            if (typeof id === 'string') {
                this.postSdkResponseWithFunc(sourceWindow, handlerName, [id]);
            }
            else {
                this.log("JSWebModule: Failed to call handler", this.logType.LogWarning);
            }
        }
    },

    // API that posts native MessageResponse object to the listener
    postSdkResponseWithId: function(sdkWindow, id, args) {
        var response = {
            id: id,
            args: args || []
        };
        this.postSdkResponse(sdkWindow, response)
    },

    postSdkResponseWithFunc: function(sdkWindow, func, args) {
        var response = {
            func: func,
            args: args || []
        };

        this.postSdkResponse(sdkWindow, response)
    },

    postSdkResponse: function(sdkWindow, response) {

        // Uncomment to debug log the response object
        // this.debugLog(response);

        if (sdkWindow == window) {
            var event = {
                data: response
            }
            window.onNativeMessage(event);
        }
        else {
            window.postMessage(response, "*");
        }
    },

    log: function(info, logType) {
        // Uncomment to generate console logs.
        // console.log(info);
        webkit.messageHandlers.listener.postMessage({ "event" : "Log" , "logType": logType, "value" : info });
    },

    isValidSdkRequest: function(messageRequest) {
        if (!messageRequest) {
            this.log("Invalid event",  this.logType.LogError);
            return false;
        }

        if (typeof messageRequest.func !== 'string') {
            this.log("Invalid event: func not specified",  this.logType.LogError );
            return false;
        }

        if (typeof messageRequest.id !== 'number') {
            this.log("Invalid event: id not specified",  this.logType.LogError);
            return false;
        }

        if (!Array.isArray(messageRequest.args)) {
            this.log("Invalid event: args not specified",  this.logType.LogError);
            return false;
        }

        return true;
    },

    sdkRequest: function(id, func, args) {
        this.id = id;
        this.func = func;
        this.args = args;
    },

    // This method is called by the native code to pass the auth token.
    handleResponseFromNative: function(response, requestId) {
        var callback = (this.callbacks[requestId]).bind(this);
        if (callback) {
            callback(response);
            // Remove the callback to only let the callback get called once and to free up memory.
            delete this.callbacks[requestId];
        }
    },

    handleResponseHandlerFromNative: function(response, requestId) {
        var handler = (this.handlers[requestId]).bind(this);
        if (handler) {
            handler(response);
        }

        this.log("JSWebModule: callback called", this.logType.LogInfo);
    },

    handleBackButtonPress: function() {
        if (typeof window.onNativeMessage == "function") {
            this.handleResponseHandlerFromNative(null, "backButtonPress")
        } else {
            webkit.messageHandlers.listener.postMessage({ "event" : "localNavigateBack" });
        }
    },

    handleSaveSettings: function() {
        if (typeof window.onNativeMessage == "function") {
            this.handleResponseHandlerFromNative(null, "settings.save")
        }
    },

    handleRemoveSettings: function() {
        if (typeof window.onNativeMessage == "function") {
            this.handleResponseHandlerFromNative(null, "settings.remove")
        }
    },

    debugLog: function(jsobject) {
        var output = '';
        for (var property in jsobject) {
            output += property + ': ' +  jsobject[property]+'; ';
        }
        console.log(output);
    }
};

// Setup back button handler on script load
window.nativeInterface.setupBackButtonHandler();
window.nativeInterface.setupSaveSettingsHandler();
window.nativeInterface.setupRemoveSettingsHandler();

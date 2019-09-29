//
//  PAM.swift
//  PamSdk
//
//  Created by narongrit kanhanoi on 26/9/2562 BE.
//  Copyright © 2562 PAM. All rights reserved.
//

import UIKit
import UserNotifications

public class PAM {

    static let DEVICE_UUID = "deviceUUID"
    static let DEVICE_PUSH_TOKEN = "devicePushToken"
    private static var _instance:PAM! = nil
    private var onRemoteNotificationDidRegistered:RegisterPushNotiCallback?

    var pamServer:String?
    var deviceUUID:String?
    var appId:String?

    deinit {
        
    }

    public static var enableLog: Bool {
        get{
            return Logger.enableLog
        }
        set{
            Logger.enableLog = newValue
        }
    }

    static var current:PAM{
        get{
            if _instance == nil {
                _instance = PAM()
            }
            return _instance
        }
    }

    init(){
        
    }

    public static func setup(pamServer:String?){
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            current.deviceUUID = uuid
            UserDefaults.standard.setValue(uuid, forKey: DEVICE_UUID)
            UserDefaults.standard.synchronize()
        }

        if let pamServer = pamServer{
            if pamServer.hasSuffix("/"){
                current.pamServer = pamServer
            }else{
                current.pamServer = "\(pamServer)/"
            }
        }
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            current.appId = bundleIdentifier
        }

    }

    public static func askNotificationPermissionIfNeeded( pushKeyCallBack:@escaping RegisterPushNotiCallback ){
        current.onRemoteNotificationDidRegistered = pushKeyCallBack
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]){ (granted, error) in
            if error != nil{
                current.onRemoteNotificationDidRegistered?(error, nil )
            }
        }
    }

    public static func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data){
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.setValue(token, forKey: PAM.DEVICE_PUSH_TOKEN)
        UserDefaults.standard.synchronize()
        PAM.current.onRemoteNotificationDidRegistered?(nil, token)
    }

    public static func trackCustomEvent(event:PAMEvent){
        
    }

    public static func trackPageview(pageName:String){
        let event = PAMEvent()
        event.pageName = pageName
        trackCustomEvent(event: event)
    }

    public static func trackClick(){
        let event = PAMEvent()
        trackCustomEvent(event: event)
    }

    public static func setUserLanguage(){
        let event = PAMEvent()
        trackCustomEvent(event: event)
    }

    public static func setUserTags(tags:[String]){
        let event = PAMEvent()
        trackCustomEvent(event: event)
    }

    public static func setUserTag(tag:String){
        let event = PAMEvent()
        trackCustomEvent(event: event)
    }

}

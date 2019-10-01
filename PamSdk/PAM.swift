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

    private let DEVICE_UUID = "deviceUUID"
    private let DEVICE_PUSH_TOKEN = "devicePushToken"
    private var onRemoteNotificationDidRegistered: RegisterPushNotiCallback?

    private var pamServer: String! = nil
    private var deviceUUID: String?
    private var appId: String?
    private var pushNotiKeyMediaAlias: String?

    private var cacheContactID: String? = nil
    
    private static var _instance: PAM?
    public static var main: PAM {
        get {
            if _instance == nil {
                _instance = PAM(pamServer: "")
            }
            return _instance!
        }
        set {
            _instance = newValue
        }
    }

    private let apiClient: APIClient

    public init(pamServer: String ){

        apiClient = APIClient(pamServer: pamServer)
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            deviceUUID = uuid
            UserDefaults.standard.setValue(uuid, forKey: DEVICE_UUID)
            UserDefaults.standard.synchronize()
        }

        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            appId = bundleIdentifier
        }

        if let event = getAppUpgradeEvent() {
            trackCustomEvent(event: event)
        }

        PAM._instance = self
    }

    public func openFromURL(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {

        // Determine who sent the URL.
        let sendingAppID = options[.sourceApplication]
        print("source application = \(sendingAppID ?? "Unknown")")

        // Process the URL.
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let path = components.path,
            let params = components.queryItems else {
                print("Invalid URL or album path missing")
                return false
        }

        print("PATH > = \(path)")
        print("PARAM > = \(params)")

        return false
    }

    public var enableLog: Bool {
        get {
            return Logger.enableLog
        }
        set {
            Logger.enableLog = newValue
        }
    }

    public func getDeviceUUID()->String?{
        return deviceUUID
    }

    public func askNotificationPermissionIfNeeded(mediaAlias:String ,pushKeyCallBack: @escaping RegisterPushNotiCallback) {
        onRemoteNotificationDidRegistered = pushKeyCallBack
        self.pushNotiKeyMediaAlias = mediaAlias
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let notificationSettings: UNNotificationSettings? = settings
            if notificationSettings?.authorizationStatus == .authorized {
                DispatchQueue.main.sync {
                    Logger.log("REQUEST PUSH KEY 1")
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }else{
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                    if error != nil {
                        self.onRemoteNotificationDidRegistered?(error, nil)
                    } else {
                        DispatchQueue.main.sync {
                            Logger.log("REQUEST PUSH KEY 2")
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }
            }
        }
    }

    public func didRegisterPushNotificationError(error: Error) {
        trackPushTokenError(error: error)
        onRemoteNotificationDidRegistered?(error, nil)
    }

    public func didRegisterPushNotification(deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        trackPushToken(pushToken: token)

        UserDefaults.standard.setValue(token, forKey: DEVICE_PUSH_TOKEN)
        UserDefaults.standard.synchronize()

        Logger.log("GOT PUSH KEY 1\(token)")
        onRemoteNotificationDidRegistered?(nil, token)
    }

    public func trackCustomEvent(event: PAMEvent) {
        DispatchQueue.global(qos: .background).async {
            self.apiClient.sendEvent(event: event)
        }
    }

    public func trackPageview(pageName: String, contentId: String? = nil, pageURL: String? = nil, contentTitle: String? = nil) {

        let event = PAMEvent()
        event.eventName = "page_view"
        event.formData.customData = ["page_name": pageName]

        if contentTitle != nil {
            event.pageTitle = contentTitle
        } else {
            event.pageTitle = pageName
        }

        if let contentId = contentId {
            event.formData.customData["content_id"] = contentId
        }
        if let contentURL = pageURL {
            event.pageURL = contentURL
        }

        if let contentTitle = contentTitle {
            event.formData.customData["content_title"] = contentTitle
        }

        trackCustomEvent(event: event)
    }

    public func trackPushToken(pushToken: String?) {
        guard let mediaAlias = pushNotiKeyMediaAlias, let pushToken = pushToken else { return }
        let event = PAMEvent()
        event.eventName = "save_push_noti_token"
        event.formData.customData[mediaAlias] = pushToken
        trackCustomEvent(event: event)
    }

    public func trackPushTokenError(error: Error?) {
        guard let error = error else{return}
        let event = PAMEvent()
        event.eventName = "push_noti_register_error"
        event.formData.customData["error"] = error.localizedDescription
        trackCustomEvent(event: event)
    }

    public func trackClick() {
        let event = PAMEvent()
        trackCustomEvent(event: event)
    }

    public func setUserLanguage() {
        let event = PAMEvent()
        trackCustomEvent(event: event)
    }

    public func setUserTags(tags: [String]) {
        let event = PAMEvent()
        trackCustomEvent(event: event)
    }

    public func setUserTag(tag: String) {
        let event = PAMEvent()
        trackCustomEvent(event: event)
    }

    public func saveContactID(id: String?) {
        if cacheContactID != id {
            if cacheContactID == "" {return}
            cacheContactID = id
            UserDefaults.standard.setValue(id, forKey: "pam_contact_id")
        }
    }

    public func getContactID() -> String? {
        if let cacheContactID = cacheContactID {
            return cacheContactID
        }
        cacheContactID = UserDefaults.standard.string(forKey: "pam_contact_id")
        return cacheContactID
    }

    public func cleanEverything(){
        UserDefaults.standard.removeObject(forKey: "pam_contact_id")
    }

}

extension PAM {

    private func getAppUpgradeEvent() -> PAMEvent? {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let versionOfLastRun = UserDefaults.standard.object(forKey: "VersionOfLastRun") as? String
        UserDefaults.standard.set(currentVersion, forKey: "VersionOfLastRun")
        UserDefaults.standard.synchronize()

        if versionOfLastRun == nil {
            // First start after installing the app
            let event = PAMEvent()
            event.eventName = "app_first_launch"

            return event
        } else if versionOfLastRun != currentVersion {
            // App was updated since last run
            let event = PAMEvent()
            event.eventName = "app_updated"
            return event
        }

        // nothing changed
        return nil
    }


}

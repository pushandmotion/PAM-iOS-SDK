//
//  EventData.swift
//  PamSdk
//
//  Created by narongrit kanhanoi on 26/9/2562 BE.
//  Copyright © 2562 PAM. All rights reserved.
//

import UIKit


public class PAMEvent{

    public static let add_payment_info = "add_payment_info"
    public static let add_to_cart = "add_to_cart"
    public static let add_to_wishlist = "add_to_wishlist"
    public static let begin_checkout = "begin_checkout"
    public static let checkout_progress = "checkout_progress"
    public static let generate_lead = "generate_lead"
    public static let login = "login"
    public static let purchase = "purchase"
    public static let refund = "refund"
    public static let remove_from_cart = "remove_from_cart"
    public static let search = "search"
    public static let select_content = "select_content"
    public static let set_checkout_option = "set_checkout_option"
    public static let share = "share"
    public static let sign_up = "sign_up"
    public static let view_item = "view_item"
    public static let view_item_list = "view_item_list"
    public static let view_promotion = "view_promotion"
    public static let view_search_results = "view_search_results"

    public static let open_from_url_scheme = "open_from_url_scheme"

    var eventName:String?  = nil
    var pageName:String?  = nil
    var formData:Form  = Form()
    var customHeader:[String:String]? = nil
    var pageURL:String? = nil
    var pageTitle:String? = nil

    func toDictionary()->[String:Any]{

        var dictionary = [String:Any]()

        formData.customData["platform"] = "iOS"
        formData.customData["device_model"] = UIDevice.modelName
        formData.customData["os_version"] = UIDevice.current.systemVersion
        formData.customData["app_name"] = Bundle.main.bundleIdentifier
        formData.customData["app_version"] = "\(Bundle.main.releaseVersionNumber ?? "") (\(Bundle.main.buildVersionNumber ?? ""))"

        let screenBound = UIScreen.main.bounds
        formData.customData["screen_width"] = "\(Int(screenBound.width))"
        formData.customData["screen_height"] = "\(Int(screenBound.height))"

        #if DEBUG
            formData.customData["app_environment"] = "Development"
        #else
            formData.customData["app_environment"] = "Production"
        #endif

        if let eventName = eventName{
            dictionary["event"] = eventName
        }
        if let pageURL = pageURL{
            dictionary["page_url"] = pageURL
        }
        if let pageTitle = pageTitle{
            dictionary["page_title"] = pageTitle
        }

        dictionary["form_fields"] = formData.toDictionary()

        return dictionary
    }
    
}

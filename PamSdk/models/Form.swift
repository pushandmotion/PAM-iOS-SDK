//
//  Form.swift
//  PamSdk
//
//  Created by narongrit kanhanoi on 26/9/2562 BE.
//  Copyright © 2562 PAM. All rights reserved.
//

import UIKit


class Form {
    var firstname: String?
    var lastname: String?
    var email: String?
    var mobile: String?
    var transactionCampaignID: String?
    var customData: [String: String] = [:]

    var contactID: String? = PAM.main.getContactID()

    func toDictionary() -> [String: String] {
        var dict: [String: String] = [:]
        if let transactionCampaignID = transactionCampaignID {
            dict["_campaign"] = transactionCampaignID
        }
        if let firstname = firstname {
            dict["firstname"] = firstname
        }
        if let lastname = lastname {
            dict["lastname"] = lastname
        }
        if let email = email {
            dict["email"] = email
        }
        if let mobile = mobile {
            dict["mobile"] = mobile
        }
        if let contactID = contactID {
            dict["_contact_id"] = contactID
        }

        customData.forEach { (key, value) in
            dict[key] = value
        }

        return dict
    }



}

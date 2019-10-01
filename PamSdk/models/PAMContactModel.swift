//
//  PAMContactModel.swift
//  PamSdk
//
//  Created by narongrit kanhanoi on 30/9/2562 BE.
//  Copyright © 2562 PAM. All rights reserved.
//


struct PAMContactModel: Codable {
    var contactID:String? = nil
    enum CodingKeys: String, CodingKey {
           case contactID = "contact_id"
    }
}

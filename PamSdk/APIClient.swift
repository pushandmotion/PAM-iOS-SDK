//
//  APIClient.swift
//  PamSdk
//
//  Created by narongrit kanhanoi on 26/9/2562 BE.
//  Copyright © 2562 PAM. All rights reserved.
//

import UIKit

class APIClient {
    let session:URLSession?
    init(){
        session = URLSession(configuration: URLSessionConfiguration.default)
    }

    func eventAPI() -> String? {
        if let server = PAM.current.pamServer {
            return "\(server)trackers/events"
        }
        return nil
    }
}

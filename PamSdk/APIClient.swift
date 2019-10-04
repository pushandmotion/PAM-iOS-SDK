//
//  APIClient.swift
//  PamSdk
//
//  Created by narongrit kanhanoi on 26/9/2562 BE.
//  Copyright © 2562 PAM. All rights reserved.
//

import UIKit

class APIClient {
    let session: URLSession? = nil
    var eventAPIURL: String! = nil
    let pamServer: String
    var _urlSession: URLSession?

    init(pamServer: String) {
        self.pamServer = pamServer
    }

    private func getSharedURLSession() -> URLSession {
        if _urlSession == nil {
            _urlSession = URLSession(configuration: .default)
        }
        return _urlSession!
    }

    func getEventAPIURL() -> String? {
        if eventAPIURL != nil && eventAPIURL != "" {
            return eventAPIURL
        }
        if pamServer.hasSuffix("/") {
            eventAPIURL = "\(pamServer)trackers/events"
        } else {
            eventAPIURL = "\(pamServer)/trackers/events"
        }
        if eventAPIURL == "" {
            return nil
        }

        return eventAPIURL
    }

    func sendEvent(event: PAMEvent) {
        guard let apiURL = getEventAPIURL() else { return }
        guard let url = URL(string: apiURL) else { return }

        let jsonBody = try? JSONSerialization.data(withJSONObject: event.toDictionary(), options: .prettyPrinted)

        let urlSession = getSharedURLSession()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        urlSession.dataTask(with: request) { data, response, error in

            if let data = data {
                let decode = JSONDecoder()
                if let contactModel = try? decode.decode(PAMContactModel.self, from: data) {
                    DispatchQueue.main.sync {
                        if let contactID = contactModel.contactID {
                            PAM.main.saveContactID(id: contactID)
                            Logger.log("Contact ID = ", contactID)
                        }
                    }
                }
            }

        }.resume()

    }


}

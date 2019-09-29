//
//  ViewController.swift
//  Example
//
//  Created by narongrit kanhanoi on 26/9/2562 BE.
//  Copyright © 2562 PAM. All rights reserved.
//

import UIKit
import PamSdk

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func requestPushNotiPermission(_ sender: Any) {
        PAM.askNotificationPermissionIfNeeded{ (error, token) in
            print(token)
        }
    }

}


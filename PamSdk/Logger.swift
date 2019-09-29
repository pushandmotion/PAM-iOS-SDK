//
//  Logger.swift
//  PamSdk
//
//  Created by narongrit kanhanoi on 26/9/2562 BE.
//  Copyright © 2562 PAM. All rights reserved.
//

import UIKit

class Logger{
    static var enableLog = true

    static func log(_ items: Any...){
        if !enableLog {return}
        #if DEBUG
        print("PAM 🦄 ",items)
        #endif
    }

}

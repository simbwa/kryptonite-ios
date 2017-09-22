//
//  Globals.swift
//  Kryptonite
//
//  Created by Alex Grinman on 8/29/16.
//  Copyright © 2016 KryptCo, Inc. Inc. All rights reserved.
//

import Foundation

//MARK: Constants
struct Constants {
    static let appGroupSecurityID = "group.co.krypt.kryptonite"
    static let defaultKeyChainService = "kr_keychain_service"
    static let teamKeyChainService = "kr_team_keychain_service"
    static let endpointARNStorageKey = "aws_endpoint_arn_key"
}

//MARK: Platform Detection
struct Platform {
    static let isDebug:Bool = {
        var debug = false
        #if DEBUG
            debug = true
        #endif
        return debug
    }()

    static let isSimulator: Bool = {
        var sim = false
        #if arch(i386) || arch(x86_64)
            sim = true
        #endif
        return sim
    }()
}



//MARK: Defaults

extension UserDefaults {
    static var  group:UserDefaults? {
        return UserDefaults(suiteName: Constants.appGroupSecurityID)
    }
}

//MARK: Dispatch
func dispatchMain(task:@escaping ()->Void) {
    DispatchQueue.main.async {
        task()
    }
}

func dispatchAsync(task:@escaping ()->Void) {
    DispatchQueue.global().async {
        task()
    }
    
}

func dispatchAfter(delay:Double, task:@escaping ()->Void) {
    
    let delay = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    
    DispatchQueue.main.asyncAfter(deadline: delay) {
        task()
    }
}




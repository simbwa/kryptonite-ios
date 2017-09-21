//
//  Request+Notify.swift
//  Kryptonite
//
//  Created by Alex Grinman on 6/23/17.
//  Copyright © 2017 KryptCo. All rights reserved.
//

import Foundation

extension Request {
    
    /**
        Get a notification subtitle and body message
     */
    func notificationDetails()  -> (subtitle:String, body:String) {
        switch self.body {
        case .ssh(let sshSign):
            return ("SSH Login", sshSign.display)
        case .git(let gitSign):
            let git = gitSign.git
            return (git.subtitle + " Signature", git.shortDisplay)
        case .createTeam(let create):
            return ("Teams", "Do you want to create team \(create.name)?")
        case .adminKey:
            return ("Teams", "Trust this computer to administer your team?")
        case .me:
            return ("Identity Request", "Public key exported")
        case .unpair:
            return ("Unpair", "Device has been unpaired")
        case .noOp:
            return ("", "Ping")
        }
    }
}

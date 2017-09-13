//
//  TeamInvite.swift
//  Kryptonite
//
//  Created by Alex Grinman on 7/20/17.
//  Copyright © 2017 KryptCo. All rights reserved.
//

import Foundation

enum TeamJoinType {
    case invite(TeamInvite)
    case create(Request, Session)
}

struct TeamInvite {
    let initialTeamPublicKey:SodiumPublicKey
    let blockHash:Data
    let seed:Data
}

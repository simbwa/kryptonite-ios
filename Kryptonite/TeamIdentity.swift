//
//  Identity.swift
//  Kryptonite
//
//  Created by Alex Grinman on 7/20/17.
//  Copyright © 2017 KryptCo. All rights reserved.
//

import Foundation
import Sodium
import JSON

struct TeamIdentity:Jsonable {
    let id:Data
    var email:String
    let keyPair:SodiumKeyPair
    private let keyPairSeed:Data
    
    private let teamID:Data
    var checkpoint:Data
    let initialTeamPublicKey:SodiumPublicKey

    /**
        Team Persistance
     */
    var dataManager:TeamDataManager
    var team:Team
    
    mutating func set(team:Team) throws {
        try dataManager.set(team: team)
        self.team = team        
    }
    
    enum Errors:Error {
        case keyPairFromSeed
        case signingError
    }
    
    var createTeamResponse:CreateTeamResponse {
        return CreateTeamResponse(seed: keyPairSeed.toBase64(), error: nil)
    }
    
    /**
        Create a new identity with an email for use with `team`
     */
    static func newAdmin(email:String, teamName:String) throws -> (TeamIdentity, HashChain.Block) {
        let id = try Data.random(size: 32)
        let teamID = try Data.random(size: 32)
        let keyPairSeed = try Data.random(size: KRSodium.shared().sign.SeedBytes)
        
        guard let keyPair = try KRSodium.shared().sign.keyPair(seed: keyPairSeed) else {
            throw Errors.keyPairFromSeed
        }
        
        // create the first block
        let createChain = HashChain.CreateChain(teamPublicKey: keyPair.publicKey, teamInfo: Team.Info(name: teamName))
        let payload = HashChain.Payload.create(createChain)
        let payloadData = try payload.jsonData()
        
        // sign the payload
        guard let signature = try KRSodium.shared().sign.signature(message: payloadData, secretKey: keyPair.secretKey)
        else {
            throw Errors.signingError
        }
        
        // create the block
        let createBlock = try HashChain.Block(publicKey: keyPair.publicKey, payload: payloadData.utf8String(), signature: signature)
        let checkpoint = createBlock.hash()

        let team = Team(info: Team.Info(name: teamName), lastBlockHash: checkpoint)
        let teamIdentity = try TeamIdentity(id: id, email: email, keyPairSeed: keyPairSeed, teamID: teamID, checkpoint: checkpoint, initialTeamPublicKey: keyPair.publicKey, team: team)

        return (teamIdentity, createBlock)
    }

    static func newMember(email:String, teamName:String = "", checkpoint:Data, initialTeamPublicKey:SodiumPublicKey) throws -> TeamIdentity {
        let id = try Data.random(size: 32)
        let teamID = try Data.random(size: 32)
        let keyPairSeed = try Data.random(size: KRSodium.shared().sign.SeedBytes)
        
        let team = Team(info: Team.Info(name: teamName))
        return try TeamIdentity(id: id, email: email, keyPairSeed: keyPairSeed, teamID: teamID, checkpoint: checkpoint, initialTeamPublicKey: initialTeamPublicKey, team: team)
    }
    
    private init(id:Data, email:String, keyPairSeed:Data, teamID:Data, checkpoint:Data, initialTeamPublicKey:SodiumPublicKey, team:Team) throws {
        self.id = id
        self.email = email
        self.keyPairSeed = keyPairSeed
        guard let keyPair = try KRSodium.shared().sign.keyPair(seed: keyPairSeed) else {
            throw Errors.keyPairFromSeed
        }
        self.keyPair = keyPair
        
        self.teamID = teamID
        self.checkpoint = checkpoint
        self.initialTeamPublicKey = initialTeamPublicKey
        self.dataManager = TeamDataManager(teamID: teamID)
        self.team = team
    }
    
    init(json: Object) throws {
        let teamID:Data = try ((json ~> "team_id") as String).fromBase64()
        let keyPairSeed:Data = try ((json ~> "keypair_seed") as String).fromBase64()
        

        try self.init(id: ((json ~> "id") as String).fromBase64(),
                      email: json ~> "email",
                      keyPairSeed: keyPairSeed,
                      teamID: teamID,
                      checkpoint: ((json ~> "checkpoint") as String).fromBase64(),
                      initialTeamPublicKey: ((json ~> "inital_team_public_key") as String).fromBase64(),
                      team: TeamDataManager(teamID: teamID).fetchTeam())
    }
    
    var object: Object {
        return    ["id": id.toBase64(),
                   "email": email,
                   "keypair_seed": keyPair.secretKey.toBase64(),
                   "team_id": teamID.toBase64(),
                   "checkpoint": checkpoint.toBase64(),
                   "inital_team_public_key": initialTeamPublicKey.toBase64()]
        
    }
    
    /** 
        Chain Validity
     */
    
    func isCheckPointReached() throws -> Bool {
        return try dataManager.hasBlock(for: checkpoint)
    }
    
    /**
        Is Admin
     */
    func isAdmin() throws -> Bool {
        return try dataManager.isAdmin(for: keyPair.publicKey)
    }
}


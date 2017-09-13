//
//  TeamDataManagerTests.swift
//  Kryptonite
//
//  Created by Alex Grinman on 8/30/17.
//  Copyright © 2017 KryptCo. All rights reserved.
//

import XCTest
@testable import Kryptonite

enum X {
    case a(String)
}

class TeamDataManagerTests: XCTestCase {
    
    var id:Data!
    var teamPublicKey:Data!
    
    var members:[Team.MemberIdentity]!
    var team:Team!
    
    var randomPayload:String!
    
    var randomBlock:HashChain.Block {
        return try! HashChain.Block(payload: randomPayload, signature: Data.random(size: 256))
    }
    
    override func setUp() {
        super.setUp()
        id = try! Data.random(size: 16)
        teamPublicKey = try! Data.random(size: 32)
        let users = ["eve@acme.co", "don@acme.co", "carlos@acme.co", "bob@acme.co", "alice@acme.co"]
        members = users.map {
            return try! Team.MemberIdentity(publicKey: Data.random(size: 32), email: $0, sshPublicKey: Data.random(size: 32), pgpPublicKey: Data.random(size: 32))
        }
        
        team = Team(info: Team.Info(name: "test team"))
        randomPayload = try! Data.random(size: 4096).toBase64()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateTeam() {
        let dm = TeamDataManager(teamID: id)
        
        do {
            try dm.create(team: team, block: randomBlock)
            let _ = try dm.fetchTeam()
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testConflicts() {
        let dm = TeamDataManager(teamID: id)
        
        do {
            try dm.create(team: team, block: randomBlock)
            try dm.saveContext()
            
        } catch {
            XCTFail("\(error)")
        }
        
        let b1 = HashChain.Block(payload: "some 1", signature: try! Data.random(size: 64))
        let b2 = HashChain.Block(payload: "some 2", signature: try! Data.random(size: 64))

        do {
            let dm1 = TeamDataManager(teamID: id)
            try dm1.append(block: b1)
            
            let dm2 = TeamDataManager(teamID: id)
            try dm2.append(block: b2)
            
            try dm1.saveContext()
            try dm2.saveContext()

            XCTFail("Error: should have found conflicts")
        } catch {
        }
        
        do {
            let dm1 = TeamDataManager(teamID: id)
            try dm1.append(block: b1)
            try dm1.saveContext()
            
            let dm2 = TeamDataManager(teamID: id)
            try dm2.append(block: b2)
            try dm2.saveContext()
        } catch {
            XCTFail("\(error)")
        }

    }
    
    func testTeamChanges() {
        let dm = TeamDataManager(teamID: id)
        
        let updateApproval:UInt64 = 600
        let updateName = "Test Team 2"

        do {
            try dm.create(team: team, block: randomBlock)
            let _ = try dm.fetchTeam()
            
            // policy
            var updated:Team = team
            updated.policy = Team.PolicySettings(temporaryApprovalSeconds: updateApproval)
            let block1 = randomBlock
            
            try dm.set(team: updated)
            try dm.append(block: block1)
            try dm.saveContext()
            
            var fetched = try TeamDataManager(teamID: id).fetchTeam()
            XCTAssert(fetched.policy.temporaryApprovalSeconds == updateApproval)
            XCTAssert(fetched.lastBlockHash == block1.hash())

            // name
            updated.info = Team.Info(name: updateName)
            let block2 = randomBlock
            
            try dm.set(team: updated)
            try dm.append(block: block2)
            try dm.saveContext()
            
            fetched = try TeamDataManager(teamID: id).fetchTeam()
            XCTAssert(fetched.policy.temporaryApprovalSeconds == updateApproval)
            XCTAssert(fetched.lastBlockHash == block2.hash())
            
            try XCTAssert(TeamDataManager(teamID: id).fetchTeam().info.name == updateName)
            
            // invite
            // store all team properties as well
            
            
            
        } catch {
            XCTFail("\(error)")
        }
    }
    

    
    func testBlocks() {
        let dm = TeamDataManager(teamID: id)
        
        do {
            try dm.create(team: team, block: randomBlock)
            let _ = try dm.fetchTeam()
            
        } catch {
            XCTFail("\(error)")
        }
    }


    func testMembers() {
        _ = Team(info: Team.Info(name: "test team"))
        
    }
    
    func testPinnedHosts() {
        let team = Team(info: Team.Info(name: "test team"))
        let createPayload = try! HashChain.CreateChain(teamPublicKey: teamPublicKey, teamInfo: team.info).jsonString()
        let createSignature = try! Data.random(size: 64)
        let createBlock = HashChain.Block(payload: createPayload, signature: createSignature)
        
        let dm = TeamDataManager(teamID: id)
        
        do {
            try dm.create(team: team, block: createBlock)
            let _ = try dm.fetchTeam()
            
        } catch {
            XCTFail("\(error)")
        }
    }

    func testSodiumEncrypt() {
        
        let bob = try! KRSodium.shared().box.keyPair()!
        let alice = try! KRSodium.shared().box.keyPair()!
        
        let data = try! Data.random(size: 256)
        
        self.measure {
            for _ in 0 ..< 100 {
                let x:Data = try! KRSodium.shared().box.seal(message: data, recipientPublicKey: alice.publicKey, senderSecretKey: bob.secretKey)!
            }
        }
    }
    
}

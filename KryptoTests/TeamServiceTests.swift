//
//  TeamServiceTests.swift
//  Kryptonite
//
//  Created by Alex Grinman on 8/3/17.
//  Copyright © 2017 KryptCo. All rights reserved.
//

import XCTest
@testable import Kryptonite

import UIKit
import JSON

class TeamServiceTests: XCTestCase {

    var teamIdentity:TeamIdentity!
    var createBlock:HashChain.Block!
    var server = MemoryTeamServerHTTP()
    
    override func setUp() {
        super.setUp()
        
        //make sure we have key
        if !KeyManager.hasKey() {
            try! KeyManager.generateKeyPair(type: .Ed25519)
        }
        
        // create the team
        let (id, create) = try! TeamIdentity.newAdmin(email: "bob@iostests.com", teamName: "iOSTests")
        teamIdentity = id
        createBlock = create
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testCreateTeam() {
        let exp = expectation(description: "TeamService ASYNC request")

        do {
            try TeamService.temporary(for: teamIdentity, server: server).createTeam(createBlock: createBlock) { (response) in
                
                switch response {
                case .error(let e):
                    XCTFail("FAIL - Server error: \(e)")
                    exp.fulfill()
                    
                case .result(let service):
                    self.teamIdentity = service.teamIdentity
                    exp.fulfill()
                }
            }
            
        } catch {
            XCTFail("FAIL: \(error)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 30.0) { (error) in
            if let e = error {
                XCTFail("FAIL - callback timeout: \(e)")
            }
        }
    }
    
}
//
//  HashChain+Verify.swift
//  Kryptonite
//
//  Created by Alex Grinman on 8/4/17.
//  Copyright © 2017 KryptCo. All rights reserved.
//

import Foundation

struct UpdatedTeam {
    let team:Team
    let lastBlockHash:Data
}

extension HashChain.Response {
    
    func verifyAndDigestBlocks(for team:Team) throws -> UpdatedTeam {
        
        let blockDataManager = HashChainBlockManager(team: team)
        
        var updatedTeam = team
        
        var blockStart = 0
        var lastBlockHash = try team.getLastBlockHash()
        
        if lastBlockHash == nil {
            guard blocks.count > 0 else {
                throw HashChain.Errors.missingCreateChain
            }
            
            let createBlock = blocks[0]
            
            // 1. verify the block signature
            guard try KRSodium.shared().sign.verify(message: createBlock.payload.utf8Data(), publicKey: team.publicKey, signature: createBlock.signature)
                else {
                    throw HashChain.Errors.badSignature
            }
            
            // 2. ensure the create block is a create chain payload
            guard case .create(let createChain) = try HashChain.Payload(jsonString: createBlock.payload)
            else {
                throw HashChain.Errors.missingCreateChain
            }
            
            // 3. check the team public key matches
            guard createChain.teamPublicKey == team.publicKey else {
                throw HashChain.Errors.teamPublicKeyMismatch
            }
            
            updatedTeam.info = createChain.teamInfo
            
            // add the block to the data store
            try blockDataManager.add(block: createBlock)
            
            lastBlockHash = createBlock.hash()
            blockStart += 1
        }
        
        var inviteNoncePublicKey:SodiumPublicKey?
        
        for i in blockStart ..< blocks.count {
            let nextBlock = blocks[i]
            
            // 1. Ensure it's an append block
            guard case .append(let appendBlock) = try HashChain.Payload(jsonString: nextBlock.payload) else {
                throw HashChain.Errors.unexpectedBlock
            }
            
            // handle special case for an accept invite signed by the invitation nonce keypair
            // otherwise, every other block must be signed by team public key
            var publicKey:SodiumPublicKey
            if case .acceptInvite = appendBlock.operation, let noncePublicKey = inviteNoncePublicKey {
                publicKey = noncePublicKey
            } else {
                publicKey = team.publicKey
            }
            
            // 2. Ensure last hash matches
            guard appendBlock.lastBlockHash == lastBlockHash else {
                throw HashChain.Errors.badBlockHash
            }
            
            
            // 3. Ensure signature verifies
            let verified = try KRSodium.shared().sign.verify(message: nextBlock.payload.utf8Data(),
                                                             publicKey: publicKey,
                                                             signature: nextBlock.signature)
            guard verified
                else {
                    throw HashChain.Errors.badSignature
            }
            
            
            // 4. digest the operation
            switch appendBlock.operation {
            case .inviteMember(let invite):
                inviteNoncePublicKey = invite.noncePublicKey
                
            case .cancelInvite:
                inviteNoncePublicKey = nil
                
            case .acceptInvite:
                break
                
            case .addMember, .removeMember:
                //TODO unhandled
                break
                
            case .setPolicy(let policy):
                updatedTeam.policy = policy
                
            case .setTeamInfo(let info):
                updatedTeam.info = info
            }
            
            // add the block to the data store
            try blockDataManager.add(block: nextBlock)
            
            lastBlockHash = nextBlock.hash()
        }
        
        return UpdatedTeam(team: updatedTeam, lastBlockHash: lastBlockHash!)
    }

}

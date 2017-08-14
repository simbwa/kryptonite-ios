//
//  TeamInvitationController.swift
//  Kryptonite
//
//  Created by Alex Grinman on 7/21/17.
//  Copyright © 2017 KryptCo. All rights reserved.
//

import Foundation
import UIKit

class TeamInvitationController:KRBaseController, UITextFieldDelegate {
    
    var joinType:TeamJoinType!
    var teamIdentity:TeamIdentity!
    
    @IBOutlet weak var teamNameLabel:UILabel!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var joinButton:UIButton!
    @IBOutlet weak var dontJoinButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinButton.layer.shadowColor = UIColor.black.cgColor
        joinButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        joinButton.layer.shadowOpacity = 0.175
        joinButton.layer.shadowRadius = 3
        joinButton.layer.masksToBounds = false
        
        teamNameLabel.text = teamIdentity.team.name
        emailTextfield.text = try? KeyManager.getMe()
        emailTextfield.isEnabled = true
        setJoin(valid: !(emailTextfield.text ?? "").isEmpty)
        
        switch joinType! {
        case .invite:
            joinButton.setTitle("JOIN", for: UIControlState.normal)
            dontJoinButton.setTitle("Don't Join", for: UIControlState.normal)
        case .create:
            joinButton.setTitle("CREATE", for: UIControlState.normal)
            dontJoinButton.setTitle("Don't Create", for: UIControlState.normal)
        }
    }
    
    
    func setJoin(valid:Bool) {
        
        if valid {
            self.joinButton.alpha = 1
            self.joinButton.isEnabled = true
        } else {
            self.joinButton.alpha = 0.5
            self.joinButton.isEnabled = false
        }
    }
    
    
    @IBAction func joinTapped() {
        
        guard let email = emailTextfield.text
        else {
            self.showWarning(title: "Error", body: "Invalid email address. Please enter a valid team email", then: {
                self.dismiss(animated: true, completion: nil)
            })
            return
        }
        
        // set the team identity's email
        teamIdentity.email = email
        
        self.performSegue(withIdentifier: "showTeamsComplete", sender: nil)
    }
    
    @IBAction func unwindToTeamInvitation(segue: UIStoryboardSegue) {}
    
    @IBAction func cancelTapped() {
        self.dontJoinTapped()
    }

    @IBAction func dontJoinTapped() {
        switch joinType! {
        case .invite:
            self.dismiss(animated: true, completion: nil)

        case .create(let request, let session):
            
            // send the failure response
            let responseType = ResponseBody.createTeam(CreateTeamResponse(seed: nil, error: "canceled"))
            
            let response = Response(requestID: request.id,
                                    endpoint: API.endpointARN ?? "",
                                    body: responseType,
                                    approvedUntil: Policy.approvedUntilUnixSeconds(for: session),
                                    trackingID: (Analytics.enabled ? Analytics.userID : "disabled"))
            
            do {
                try TransportControl.shared.send(response, for: session) {
                    self.dismiss(animated: true, completion: nil)
                }

            } catch {
                self.showWarning(title: "Error", body: "Couldn't send failure response to \(session.pairing.displayName).") {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = textField.text ?? ""
        let txtAfterUpdate = (text as NSString).replacingCharacters(in: range, with: string)
        
        setJoin(valid: !txtAfterUpdate.isEmpty)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let completeController = segue.destination as? TeamJoinCompleteController {
            completeController.joinType = joinType
            completeController.teamIdentity = teamIdentity
        }
    }
}

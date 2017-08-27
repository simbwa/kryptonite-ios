//
//  TeamLoadController.swift
//  Kryptonite
//
//  Created by Alex Grinman on 8/4/17.
//  Copyright © 2017 KryptCo. All rights reserved.
//

import Foundation


class TeamLoadController:UIViewController, UITextFieldDelegate {
    
    
    var joinType:TeamJoinType?

    
    @IBOutlet weak var checkBox:M13Checkbox!
    @IBOutlet weak var arcView:UIView!

    @IBOutlet weak var detailLabel:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        detailLabel.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
        
        // ensure we don't have a team yet
        do {
            if let teamIdentity = try IdentityManager.getTeamIdentity() {
                self.showWarning(title: "Already on team \(teamIdentity.team.info.name)", body: "Kryptonite only supports being on one team. Multi-team support is coming soon!")
                {
                    self.dismiss(animated: true, completion: nil)
                }
                return
            }
            
        } catch {
            self.showWarning(title: "Error", body: "Couldn't get team information.") {
                self.dismiss(animated: true, completion: nil)
            }
            
            return
        }
        
        
        arcView.spinningArc(lineWidth: checkBox.checkmarkLineWidth, ratio: 0.5)

        dispatchAfter(delay: 0.3) {
            self.loadTeam()
        }
    }
    
    func loadTeam() {
        
        var teamIdentity:TeamIdentity
        do {
            switch joinType! {
            case .invite(let invite):
                teamIdentity = try TeamIdentity.new(email: "", teamPublicKey: invite.teamPublicKey)

            case .create(let request, _):
                guard case .createTeam(let create) = request.body else {
                    self.showError(message: "Invalid request.")
                    return
                }
                
                teamIdentity = try TeamIdentity.newAdmin(email: "", teamName: create.name)
            }
        } catch {
            self.showError(message: "Could not generate team identity. Reason: \(error).")
            return
        }
        
        let service = TeamService.temporary(for: teamIdentity)
        
        do {
            switch joinType! {
            case .invite(let invite):
                try service.getTeam(using: invite) { (response) in
                    switch response {
                    case .error(let e):
                        self.showError(message: "Error fetching team information. Reason: \(e)")
                        return
                        
                    case .result(let service):
                        teamIdentity = service.teamIdentity
                        
                        dispatchMain {
                            self.performSegue(withIdentifier: "showTeamInvite", sender: teamIdentity)
                        }
                    }
                }

            case .create:
                dispatchMain {
                    self.performSegue(withIdentifier: "showTeamInvite", sender: teamIdentity)
                }
            }

        } catch {
            self.showError(message: "Could not fetch team information. Reason: \(error).")
            return
        }

    }
    
    func showError(message:String) {
        dispatchMain {
            self.detailLabel.text = message
            self.detailLabel.textColor = UIColor.reject
            self.checkBox.secondaryCheckmarkTintColor = UIColor.reject
            self.checkBox.tintColor = UIColor.reject

            UIView.animate(withDuration: 0.3, animations: {
                self.arcView.alpha = 0
                self.view.layoutIfNeeded()
                
            }) { (_) in
                self.checkBox.setCheckState(M13Checkbox.CheckState.mixed, animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let teamInviteController = segue.destination as? TeamInvitationController,
            let teamIdentity = sender as? TeamIdentity
        {
            teamInviteController.joinType = joinType
            teamInviteController.teamIdentity = teamIdentity
        }
    }
    

    @IBAction func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

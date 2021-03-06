//
//  Policy+UI.swift
//  Kryptonite
//
//  Created by Alex Grinman on 2/17/17.
//  Copyright © 2017 KryptCo. All rights reserved.
//

import Foundation
import UIKit

extension Request {
    var approveController:ApproveController? {
        
        switch self.body {
        case .ssh:
            return Resources.Storyboard.Approval.instantiateViewController(withIdentifier: "SSHApproveController") as? SSHApproveController
        case .git(let gitSign):
            switch gitSign.git {
            case .commit:
                return Resources.Storyboard.Approval.instantiateViewController(withIdentifier: "CommitApproveController") as? CommitApproveController
            case .tag:
                return Resources.Storyboard.Approval.instantiateViewController(withIdentifier: "TagApproveController") as? TagApproveController
            }
        default:
            return nil
        }
    }
    
    var autoApproveDisplay:String? {
        switch self.body {
        case .ssh(let sshRequest):
            return sshRequest.display
        case .git(let gitSign):
            return gitSign.git.shortDisplay

        default:
            return nil
        }
    }
}

extension UIViewController {
    
    
    func requestUserAuthorization(session:Session, request:Request) {
        
        // remove pending
        Policy.removePendingAuthorization(session: session, request: request)
        
        // proceed to show approval request
        guard let approvalController = request.approveController else {
            log("nil approve controller", .error)
            return
        }
        
        approvalController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        approvalController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        approvalController.session = session
        approvalController.request = request
        
        dispatchMain {
            if self.presentedViewController is AutoApproveController {
                self.presentedViewController?.dismiss(animated: false, completion: {
                    self.present(approvalController, animated: true, completion: nil)
                })
            } else {
                self.present(approvalController, animated: true, completion: nil)
            }
        }
    }
    
    func showApprovedRequest(session:Session, request:Request) {
        
        // don't show if user is asked to approve manual
        guard self.presentedViewController is ApproveController == false
            else {
                return
        }
        
        // remove pending
        Policy.removePendingAuthorization(session: session, request: request)
        
        // proceed to show auto approval
        let autoApproveController = Resources.Storyboard.Approval.instantiateViewController(withIdentifier: "AutoApproveController")
        autoApproveController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        autoApproveController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        (autoApproveController as? AutoApproveController)?.deviceName = session.pairing.displayName.uppercased()
        (autoApproveController as? AutoApproveController)?.command = request.autoApproveDisplay        
        
        dispatchMain {
            if self.presentedViewController is AutoApproveController {
                self.presentedViewController?.dismiss(animated: false, completion: {
                    self.present(autoApproveController, animated: true, completion: nil)
                })
            } else {
                self.present(autoApproveController, animated: true, completion: nil)
            }
        }
    }
    
    func showFailedResponse(errorMessage:String, session:Session) {
        
        // don't show if user is asked to approve manual
        guard self.presentedViewController is ApproveController == false
            else {
                return
        }
        
        // proceed to show auto approval
        let autoApproveController = Resources.Storyboard.Approval.instantiateViewController(withIdentifier: "AutoApproveController")
        autoApproveController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        autoApproveController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        (autoApproveController as? AutoApproveController)?.deviceName = session.pairing.displayName.uppercased()
        (autoApproveController as? AutoApproveController)?.errorMessage = errorMessage
        
        
        dispatchMain {
            if self.presentedViewController is AutoApproveController {
                self.presentedViewController?.dismiss(animated: false, completion: {
                    self.present(autoApproveController, animated: true, completion: nil)
                })
            } else {
                self.present(autoApproveController, animated: true, completion: nil)
            }
        }
    }

    
    func approveControllerDismissed(allowed:Bool) {
        let result = allowed ? "allowed" : "rejected"
        log("approve modal finished with result: \(result)")
        
        // if rejected, reject all pending
        guard allowed else {
            Policy.rejectAllPendingIfNeeded()
            return
        }
        
        // send and remove pending that are already allowed
        Policy.sendAllowedPendingIfNeeded()
        
        // move on to next pending if necessary
        if let pending = Policy.lastPendingAuthorization {
            log("requesting pending authorization")
            self.requestUserAuthorization(session: pending.session, request: pending.request)
        }
        
    }
}

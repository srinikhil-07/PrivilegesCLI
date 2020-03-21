//
//  
//  com.privilege.helper
//
//  Created byNikhil on 3/15/20.
//  Copyright © 2020 Nikhil. All rights reserved.
//



// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.

import Foundation
import XPC
import Collaboration
/// Class conforming to XPC listener delgate.
///
/// This class starts the service, listens to the requests and handles them
/// - ToDo: 1. Handle security aspect for the requests, 2. Analyse Swift solution for CSIdentity
///
class PrivilegeListener: NSObject, NSXPCListenerDelegate, ListenerProtocol {
    var privilegeListener = NSXPCListener()
    var serviceStarted = false
    /// Initialize the listener
    override init() {
        NSLog("Initializing the daemon service")
        privilegeListener = NSXPCListener.init(machServiceName: "com.privilege.helper")
        super.init()
        privilegeListener.delegate = self
        serviceStarted = false
    }
    /// Resume the listener
    func startService() throws {
        guard serviceStarted == false else {
            NSLog("Service start failed")
            throw ListenerError.serviceAlreadyResumed
        }
        NSLog("Resuming the service")
        serviceStarted = true
        privilegeListener.resume()
    }
    /// Suspend the listener
    func stopService() throws {
        guard serviceStarted == true else {
            NSLog("Service stop failed")
            throw ListenerError.serviceAlreadySuspended
        }
        serviceStarted = false
        privilegeListener.suspend()
    }
    /// XPC method to change privilege of the user
    ///
    /// This method checks if the given user doesnt have the requested privilege already.
    /// If not the prvivilege change is handledc else remains quiet
    ///
    /// - Parameters:
    ///     - user: user name string
    ///     - toAdmin: admin/user privilege request
    ///
    func changePrivilege(for user: String,toAdmin: Bool) {
        if let userId = CBIdentity.init(name: user, authority: .default()) {
            if let adminGroupId = CBGroupIdentity.init(posixGID: 80, authority: .local()) {
                if toAdmin && userId.isMember(ofGroup: adminGroupId) {
                    NSLog("User already admin")
                } else if !toAdmin && !userId.isMember(ofGroup: adminGroupId) {
                    NSLog("User already not admin")
                } else {
                    NSLog("Privilege change needed")
                    let obj = bridger.init()
                    if let csUserId = obj.getUserCSIdentity(for: userId) {
                        if let csGroupId = obj.getGroupCSIdentity(for: adminGroupId) {
                            let csUserIdRetained = csUserId.takeUnretainedValue()
                            let csGroupIdRetained = csGroupId.takeUnretainedValue()
                            if toAdmin {
                                NSLog("Setting admin rights to the user")
                                CSIdentityAddMember(csGroupIdRetained,csUserIdRetained)
                            } else {
                                NSLog("Stripping admin rights to the user")
                                CSIdentityRemoveMember(csGroupIdRetained, csUserIdRetained )
                            }
                            if let csGroupId2 = obj.getGroupCSIdentity(for: adminGroupId) {
                                let csGroupIdRetained2 = csGroupId2.takeUnretainedValue()
                                NSLog("committing the changes")
                                let status = CSIdentityCommit(csGroupIdRetained2, nil, nil)
                                if status {
                                    checkMembershipInAdminUser(for: user)
                                }
                            }
                        }
                    }
                }
            } else {
                NSLog("Error in creating group identity")
            }
        }
    }
    /// Test method for XPC
    func upperCaseString(_ string: String, withReply reply: @escaping (String) -> Void) {
        NSLog("Request received for upper casing - test logger")
        let response = string.uppercased()
        reply(response)
    }
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        NSLog("Request to listner recieved")
        newConnection.exportedInterface = NSXPCInterface.init(with: ListenerProtocol.self)
        newConnection.exportedObject = self
        newConnection.resume()
        return true
    }
}
/// Extending the listener
extension PrivilegeListener {
    enum ListenerError : Error {
        case serviceAlreadyResumed
        case serviceAlreadySuspended
    }
}
/// Extending helper for helper methods
extension PrivilegeListener {
    /// Method to check group membership of a user
    func checkMembershipInAdminUser(for user: String) {
        if let userId = CBIdentity.init(name: user, authority: .default()) {
        if let adminGroupId = CBGroupIdentity.init(posixGID: 80, authority: .local()) {
            NSLog("Is user %@ member of admin? %@", user, String(describing: userId.isMember(ofGroup: adminGroupId)))
            }
        }
    }
}

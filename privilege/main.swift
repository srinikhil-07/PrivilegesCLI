//
//  main.swift
//  privilege
//
//  Created by sri-7348 on 3/14/20.
//  Copyright © 2020 Nikhil. All rights reserved.
//

import Foundation
import com_privilege_helper



print("Hello, World!")

let connection = NSXPCConnection(machServiceName: "com.privilege.helper", options: .privileged)
connection.remoteObjectInterface = NSXPCInterface(with: ListenerProtocol.self)
connection.resume()
let service = connection.remoteObjectProxyWithErrorHandler { error in
    print("Error if any: \(error)")
} as? ListenerProtocol
service?.changePrivilege(toAdmin: false)
service?.upperCaseString("hello XPC") { response in
    print("Response from XPC service:", response)
}

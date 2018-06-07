//
//  AuthenticationService.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit
import NetworkKit

struct AuthenticationService: JSendService {
    
    // MARK: - JSendService Protocol
    typealias PrimaryResource = RoadChatKit.BearerToken.PublicBearerToken
    let client: JSendAPIClient
    
    init(hostname: String, port: Int?, credentials: APICredentialStore?) {
        self.client = JSendAPIClient(hostname: hostname, port: port, basePath: "user", credentials: credentials)
    }
    
    // MARK: - Public Methods
    func login(_ user: LoginRequest, completion: @escaping (PrimaryResource?, Error?) -> Void) throws {
        try client.makePOSTRequest(to: "/login", body: user) { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func logout(completion: @escaping (Error?) -> Void) {
        client.makeGETRequest(to: "/logout") { result in
            completion(self.getError(from: result))
        }
    }
    
}

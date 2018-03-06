//
//  LoginService.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

final class LoginService: JSendService {
    typealias Resource = RoadChatKit.BearerToken.PublicBearerToken
    
    private let client = JSendAPIClient(baseURL: "http://localhost:8080/user", token: nil)
    
    func login(user: LoginRequest, completion: @escaping (RoadChatKit.BearerToken.PublicBearerToken?, Error?) -> Void) throws {
        try client.makePOSTRequest(to: "/login", body: user, completion: { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        })
    }
}

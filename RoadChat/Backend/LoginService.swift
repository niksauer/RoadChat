//
//  LoginService.swift
//  RoadChat
//
//  Created by Niklas Sauer on 05.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

final class LoginService {
    private let client = JSendAPIClient(baseURL: "http://localhost:8080/user", token: nil)
    
    func login(user: LoginRequest, completion: (BearerToken.PublicBearerToken) -> Void) throws {
        try client.makePOSTRequest(to: "login", body: user, completion: { result in
            print(result)
        })
    }
}

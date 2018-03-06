//
//  UserService.swift
//  RoadChat
//
//  Created by Niklas Sauer on 06.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

final class UserService: JSendService {
    typealias Resource = RoadChatKit.User.PublicUser
    
    private let client = JSendAPIClient(baseURL: "http://localhost:8080/user", token: nil)
    
    func create(_ user: RoadChatKit.RegisterRequest, completion: @escaping (Resource?, Error?) -> Void) throws {
        try client.makePOSTRequest(to: nil, body: user) { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func get(userID: Int, completion: @escaping (Resource?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(userID)", params: nil) { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
}

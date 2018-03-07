//
//  TrafficService.swift
//  RoadChat
//
//  Created by Phillip Rust on 07.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

final class TrafficService: JSendService {
    typealias Resource = RoadChatKit.TrafficMessage
    
    private let client = JSendAPIClient(baseURL: "http://localhost:8080/traffic", token: nil)
    
    func create(trafficMessage: RoadChatKit.TrafficMessageRequest, completion: @escaping (Resource?, Error?) -> Void) throws {
        try client.makePOSTRequest(to: "/board", body: trafficMessage) { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func index(completion: @escaping (Resource?, Error?) -> Void) throws {
        client.makeGETRequest(to: "/board", params: nil) { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func get(messageID: Int, completion: @escaping (Resource?, Error?) -> Void) throws {
        client.makeGETRequest(to: "/message/\(messageID)", params: nil) { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func delete(messageID: Int, completion: @escaping (Error?) -> Void) throws {
        client.makeDELETERequest(to: "/message/\(messageID)", params: nil) { result in
            completion(self.getError(from: result))
        }
    }
    
    func upvote(messageID: Int, completion: @escaping (Error?) -> Void) throws {
        client.makeGETRequest(to: "message/\(messageID)/upvote", params: nil) { result in
            completion(self.getError(from: result))
        }
    }
    
    func downvote(messageID: Int, completion: @escaping (Error?) -> Void) throws {
        client.makeGETRequest(to: "message/\(messageID)/downvote", params: nil) { result in
            completion(self.getError(from: result))
        }
    }
}

//
//  TrafficService.swift
//  RoadChat
//
//  Created by Phillip Rust on 07.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct TrafficService: JSendService {
    
    // MARK: - JSendService Protocol
    typealias PrimaryResource = RoadChatKit.TrafficMessage.PublicTrafficMessage
    let client: JSendAPIClient
    
    init(credentials: APICredentialStore?) {
        self.client = JSendAPIClient(baseURL: "http://141.52.39.100:8080/traffic", credentials: credentials)
    }
    
    // MARK: - Public Methods
    func create(_ trafficMessage: RoadChatKit.TrafficMessageRequest, completion: @escaping (PrimaryResource?, Error?) -> Void) throws {
        try client.makePOSTRequest(to: "/board", body: trafficMessage) { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func index(completion: @escaping ([PrimaryResource]?, Error?) -> Void) {
        client.makeGETRequest(to: "/board", params: nil) { result in
            let result = self.decode([PrimaryResource].self, from: result)
            completion(result.instance, result.error)
        }
    }
    
    func get(messageID: Int, completion: @escaping (PrimaryResource?, Error?) -> Void) {
        client.makeGETRequest(to: "/message/\(messageID)", params: nil) { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func delete(messageID: Int, completion: @escaping (Error?) -> Void) {
        client.makeDELETERequest(to: "/message/\(messageID)", params: nil) { result in
            completion(self.getError(from: result))
        }
    }
    
    func upvote(messageID: Int, completion: @escaping (Error?) -> Void) {
        client.makeGETRequest(to: "/message/\(messageID)/upvote", params: nil) { result in
            completion(self.getError(from: result))
        }
    }
    
    func downvote(messageID: Int, completion: @escaping (Error?) -> Void) {
        client.makeGETRequest(to: "/message/\(messageID)/downvote", params: nil) { result in
            completion(self.getError(from: result))
        }
    }
    
}

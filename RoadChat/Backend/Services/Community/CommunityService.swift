//
//  CommunityService.swift
//  RoadChat
//
//  Created by Malcolm Malam on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit
import NetworkKit

struct CommunityService: JSendService {
    
    // MARK: - JSendService Protocol
    typealias PrimaryResource = RoadChatKit.CommunityMessage.PublicCommunityMessage
    let client: JSendAPIClient
    
    init(hostname: String, port: Int, credentials: APICredentialStore?) {
        self.client = JSendAPIClient(hostname: hostname, port: port, basePath: "community", credentials: credentials)
    }
    
    // MARK: - Public Methods
    func create(_ communityMessage: RoadChatKit.CommunityMessageRequest, completion: @escaping (PrimaryResource?, Error?) -> Void) throws {
        try client.makePOSTRequest(to: "/board", body: communityMessage) { result in
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

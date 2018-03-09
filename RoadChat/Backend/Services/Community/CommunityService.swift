//
//  CommunityService.swift
//  RoadChat
//
//  Created by Malcolm Malam on 09.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct CommunityService: JSendService {
    
    typealias Resource = RoadChatKit.CommunityMessage.PublicCommunityMessage
    
    private let client = JSendAPIClient(baseURL: "http://141.52.39.100:8080/traffic", credentials: CredentialManager.shared)
    
    func create(_ communityMessage: RoadChatKit.CommunityMessageRequest, completion: @escaping (Resource?, Error?) -> Void) throws {
        try client.makePOSTRequest(to: "/board", body: communityMessage) { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func index(completion: @escaping ([Resource]?, Error?) -> Void) throws {
        client.makeGETRequest(to: "/board", params: nil) { result in
            let result = self.decode([Resource].self, from: result)
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
        client.makeGETRequest(to: "/message/\(messageID)/upvote", params: nil) { result in
            completion(self.getError(from: result))
        }
    }
    
    func downvote(messageID: Int, completion: @escaping (Error?) -> Void) throws {
        client.makeGETRequest(to: "/message/\(messageID)/downvote", params: nil) { result in
            completion(self.getError(from: result))
        }
    }
    
}

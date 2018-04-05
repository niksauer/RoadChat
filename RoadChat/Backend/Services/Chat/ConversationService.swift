//
//  ConversationService.swift
//  RoadChat
//
//  Created by Niklas Sauer on 08.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct ConversationService: JSendService {
    
    // MARK: - JSendService Protocol
    typealias PrimaryResource = RoadChatKit.Conversation.PublicConversation
    let client: JSendAPIClient
    
    init(credentials: APICredentialStore?) {
        self.client = JSendAPIClient(baseURL: "http://141.52.39.100:8080/chat", credentials: credentials)
    }
    
    // MARK: - Public Methods
    func create(_ conversation: RoadChatKit.ConversationRequest, completion: @escaping (PrimaryResource?, Error?) -> Void) throws {
        try client.makePOSTRequest(body: conversation) { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func getNearbyUsers(completion: @escaping ([RoadChatKit.User.PublicUser]?, Error?) -> Void) {
        client.makeGETRequest(to: "/nearby") { result in
            let result = self.decode([RoadChatKit.User.PublicUser].self, from: result)
            completion(result.instance, result.error)
        }
    }
    
    func get(conversationID: RoadChatKit.Conversation.ID, completion: @escaping (PrimaryResource?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(conversationID)") { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func delete(conversationID: RoadChatKit.Conversation.ID, completion: @escaping (Error?) -> Void) {
        client.makeDELETERequest(to: "/\(conversationID)") { result in
            completion(self.getError(from: result))
        }
    }
    
    func getMessages(conversationID: RoadChatKit.Conversation.ID, completion: @escaping ([RoadChatKit.DirectMessage.PublicDirectMessage]?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(conversationID)/messages") { result in
            let result = self.decode([RoadChatKit.DirectMessage.PublicDirectMessage].self, from: result)
            completion(result.instance, result.error)
        }
    }
    
    func createMessage(_ message: RoadChatKit.DirectMessageRequest, conversationID: RoadChatKit.Conversation.ID, completion: @escaping (RoadChatKit.DirectMessage.PublicDirectMessage?, Error?) -> Void) throws {
        try client.makePOSTRequest(to: "/\(conversationID)/messages", body: message) { result in
            let result = self.decode(RoadChatKit.DirectMessage.PublicDirectMessage.self, from: result)
            completion(result.instance, result.error)
        }
    }
    
    func getParticipants(conversationID: RoadChatKit.Conversation.ID, completion: @escaping ([RoadChatKit.Participation.PublicParticipant]?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(conversationID)/participants") { result in
            let result = self.decode([RoadChatKit.Participation.PublicParticipant].self, from: result)
            completion(result.instance, result.error)
        }
    }
    
    func accept(conversationID: RoadChatKit.Conversation.ID, completion: @escaping (Error?) -> Void) {
        client.makeGETRequest(to: "/\(conversationID)/accept") { result in
            completion(self.getError(from: result))
        }
    }
    
    func deny(conversationID: RoadChatKit.Conversation.ID, completion: @escaping (Error?) -> Void) {
        client.makeGETRequest(to: "/\(conversationID)/deny") { result in
            completion(self.getError(from: result))
        }
    }
    
}

//
//  UserService.swift
//  RoadChat
//
//  Created by Niklas Sauer on 06.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit
import UIKit

enum ImageError: Error {
    case invalidFormat
}

struct UserService: JSendService {

    // MARK: - JSendService Protocol
    typealias PrimaryResource = RoadChatKit.User.PublicUser
    let client: JSendAPIClient
    
    init(hostname: String, port: Int, credentials: APICredentialStore?) {
        self.client = JSendAPIClient(hostname: hostname, port: port, basePath: "user", credentials: credentials)
    }
    
    // MARK: - Public Methods
    func create(_ user: RoadChatKit.RegisterRequest, completion: @escaping (PrimaryResource?, Error?) -> Void) throws {
        try client.makePOSTRequest(body: user) { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func get(userID: RoadChatKit.User.ID, completion: @escaping (PrimaryResource?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(userID)") { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func update(userID: RoadChatKit.User.ID, to user: RoadChatKit.UserRequest, completion: @escaping (Error?) -> Void) throws {
        try client.makePUTRequest(to: "/\(userID)", body: user) { result in
            completion(self.getError(from: result))
        }
    }
    
    func delete(userID: RoadChatKit.User.ID, completion: @escaping (Error?) -> Void) {
        client.makeDELETERequest(to: "/\(userID)") { result in
            completion(self.getError(from: result))
        }
    }
    
    func getSettings(userID: RoadChatKit.User.ID, completion: @escaping (RoadChatKit.Settings.PublicSettings?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(userID)/settings") { result in
            let result = self.decode(RoadChatKit.Settings.PublicSettings.self, from: result)
            completion(result.instance, result.error)
        }
    }

    func updateSettings(userID: RoadChatKit.User.ID, to settings: RoadChatKit.SettingsRequest, completion: @escaping (Error?) -> Void) throws {
        try client.makePUTRequest(to: "/\(userID)/settings", body: settings) { result in
            completion(self.getError(from: result))
        }
    }
    
    func getPrivacy(userID: RoadChatKit.User.ID, completion: @escaping (RoadChatKit.Privacy.PublicPrivacy?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(userID)/settings/privacy") { result in
            let result = self.decode(RoadChatKit.Privacy.PublicPrivacy.self, from: result)
            completion(result.instance, result.error)
        }
    }
    
    func updatePrivacy(userID: RoadChatKit.User.ID, to privacy: RoadChatKit.PrivacyRequest, completion: @escaping (Error?) -> Void) throws {
        try client.makePUTRequest(to: "/\(userID)/settings/privacy", body: privacy) { result in
            completion(self.getError(from: result))
        }
    }
    
    func getProfile(userID: RoadChatKit.User.ID, completion: @escaping (RoadChatKit.Profile.PublicProfile?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(userID)/profile") { result in
            let result = self.decode(RoadChatKit.Profile.PublicProfile.self, from: result)
            completion(result.instance, result.error)
        }
    }
    
    func createOrUpdateProfile(userID: RoadChatKit.User.ID, to profile: RoadChatKit.ProfileRequest, completion: @escaping (Error?) -> Void) throws {
        try client.makePUTRequest(to: "/\(userID)/profile", body: profile) { result in
            completion(self.getError(from: result))
        }
    }

    func getCars(userID: RoadChatKit.User.ID, completion: @escaping ([RoadChatKit.Car.PublicCar]?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(userID)/cars") { result in
            let result = self.decode([RoadChatKit.Car.PublicCar].self, from: result)
            completion(result.instance, result.error)
        }
    }

    func createCar(_ car: RoadChatKit.CarRequest, userID: RoadChatKit.User.ID, completion: @escaping (RoadChatKit.Car.PublicCar?, Error?) -> Void) throws {
        try client.makePOSTRequest(to: "/\(userID)/cars", body: car) { result in
            let result = self.decode(RoadChatKit.Car.PublicCar.self, from: result)
            completion(result.instance, result.error)
        }
    }

    func getLocation(userID: RoadChatKit.User.ID, completion: @escaping (RoadChatKit.Location.PublicLocation?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(userID)/location") { result in
            let result = self.decode(RoadChatKit.Location.PublicLocation.self, from: result)
            completion(result.instance, result.error)
        }
    }
    
    func updateLocation(userID: RoadChatKit.User.ID, to location: RoadChatKit.LocationRequest, completion: @escaping (Error?) -> Void) throws {
        try client.makePUTRequest(to: "/\(userID)/location", body: location) { result in
            completion(self.getError(from: result))
        }
    }

    func getTrafficMessages(userID: RoadChatKit.User.ID, completion: @escaping ([RoadChatKit.TrafficMessage.PublicTrafficMessage]?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(userID)/trafficMessages") { result in
            let result = self.decode([RoadChatKit.TrafficMessage.PublicTrafficMessage].self, from: result)
            completion(result.instance, result.error)
        }
    }
    
    func getCommunityMessages(userID: RoadChatKit.User.ID, completion: @escaping ([RoadChatKit.CommunityMessage.PublicCommunityMessage]?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(userID)/communityMessages") { result in
            let result = self.decode([RoadChatKit.CommunityMessage.PublicCommunityMessage].self, from: result)
            completion(result.instance, result.error)
        }
    }
    
    func getConversations(userID: RoadChatKit.User.ID, completion: @escaping ([RoadChatKit.Conversation.PublicConversation]?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(userID)/conversations") { result in
            let result = self.decode([RoadChatKit.Conversation.PublicConversation].self, from: result)
            completion(result.instance, result.error)
        }
    }
    
    func getImage(userID: RoadChatKit.User.ID, completion: @escaping (RoadChatKit.PublicFile?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(userID)/image") { result in
            let result = self.decode(RoadChatKit.PublicFile.self, from: result)
            completion(result.instance, result.error)
        }
    }
    
    func uploadImage(_ image: UIImage, userID: RoadChatKit.User.ID, completion: @escaping (Data?, Error?) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 1) else {
            completion(nil, ImageError.invalidFormat)
            return
        }
        
        client.uploadMultipart(name: "file", filename: "user\(userID).jpg", data: imageData, to: "/\(userID)/image", method: .put) { result in
            completion(imageData, self.getError(from: result))
        }
    }

}



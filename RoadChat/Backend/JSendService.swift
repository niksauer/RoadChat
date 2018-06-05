//
//  JSONService.swift
//  RoadChat
//
//  Created by Niklas Sauer on 06.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation

protocol Service {
    associatedtype PrimaryResource: Decodable
    associatedtype Client: APIClient
    var client: Client { get }
    init(hostname: String, port: Int, credentials: APICredentialStore?)
    init(config: APIConfiguration)
}

extension Service {
    init(config: APIConfiguration) {
        self.init(hostname: config.hostname, port: config.port ?? 80, credentials: config.credentials)
    }
}

protocol JSendService: Service where Client == JSendAPIClient { }

extension JSendService {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) -> (instance: T?, error: Error?) {
        do {
            let decoder = JSONDecoder()
            
            decoder.dateDecodingStrategy = .formatted({
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                formatter.calendar = Calendar(identifier: .iso8601)
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                formatter.locale = Locale(identifier: "en_US_POSIX")
                return formatter
            }())
            
            let instance = try decoder.decode(T.self, from: data)
            
            return (instance, nil)
        } catch {
            return (nil, error)
        }
    }
    
    func decode<T: Decodable>(_ type: T.Type, from result: APIResult) -> (instance: T?, error: Error?) {
        switch result {
        case .success(let data):
            guard let data = data else {
                return (nil, nil)
            }
            return decode(T.self, from: data)
        case .failure(let error):
            return (nil, error)
        }
    }
    
    func decodeResource(from result: APIResult) -> (instance: PrimaryResource?, error: Error?) {
        return decode(PrimaryResource.self, from: result)
    }

    func getError(from result: APIResult) -> Error? {
        switch result {
        case .success(_):
            return nil
        case .failure(let error):
            return error
        }
    }
}

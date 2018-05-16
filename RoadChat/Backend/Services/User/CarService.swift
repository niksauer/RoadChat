//
//  CarService.swift
//  RoadChat
//
//  Created by Niklas Sauer on 06.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct CarService: JSendService {
    
    // MARK: - JSendService Protocol
    typealias PrimaryResource = RoadChatKit.Car.PublicCar
    let client: JSendAPIClient

    init(hostname: String, port: Int, credentials: APICredentialStore?) {
        self.client = JSendAPIClient(baseURL: "http://\(hostname):\(port)/car", credentials: credentials)
    }
    
    // MARK: - Public Methods
    func get(carID: RoadChatKit.Car.ID, completion: @escaping (PrimaryResource?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(carID)") { result in
            let result = self.decodeResource(from: result)
            completion(result.instance, result.error)
        }
    }
    
    func update(carID: RoadChatKit.Car.ID, to car: RoadChatKit.CarRequest, completion: @escaping (Error?) -> Void) throws {
        try client.makePUTRequest(to: "/\(carID)", body: car) { result in
            completion(self.getError(from: result))
        }
    }
    
    func delete(carID: RoadChatKit.Car.ID, completion: @escaping (Error?) -> Void) {
        client.makeDELETERequest(to: "/\(carID)") { result in
            completion(self.getError(from: result))
        }
    }
    
}

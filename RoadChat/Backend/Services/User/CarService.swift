//
//  CarService.swift
//  RoadChat
//
//  Created by Niklas Sauer on 06.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit
import UIKit
import NetworkKit

struct CarService: JSendService {
    
    // MARK: - JSendService Protocol
    typealias PrimaryResource = RoadChatKit.Car.PublicCar
    let client: JSendAPIClient

    init(hostname: String, port: Int?, credentials: APICredentialStore?) {
        self.client = JSendAPIClient(hostname: hostname, port: port, basePath: "car", credentials: credentials)
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
    
    func getImage(carID: RoadChatKit.Car.ID, completion: @escaping (RoadChatKit.PublicFile?, Error?) -> Void) {
        client.makeGETRequest(to: "/\(carID)/image") { result in
            let result = self.decode(RoadChatKit.PublicFile.self, from: result)
            completion(result.instance, result.error)
        }
    }

    func uploadImage(_ image: UIImage, carID: RoadChatKit.Car.ID, completion: @escaping (Data?, Error?) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 1) else {
            completion(nil, ImageError.invalidFormat)
            return
        }
        
        client.uploadMultipart(name: "file", filename: "car\(carID).jpg", data: imageData, to: "/\(carID)/image", method: .put) { result in
            completion(imageData, self.getError(from: result))
        }
    }

}

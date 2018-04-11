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
    
}

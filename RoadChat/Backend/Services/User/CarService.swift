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
    
    typealias Resource = RoadChatKit.Car.PublicCar
    
    let client = JSendAPIClient(baseURL: "http://141.52.39.100:8080/car", credentials: CredentialManager.shared)

}

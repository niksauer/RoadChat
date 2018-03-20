//
//  TrafficBoard.swift
//  RoadChat
//
//  Created by Niklas Sauer on 20.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit

struct TrafficBoard {
    
    // MARK: - Public Properties
    let trafficService: TrafficService
    
    // MARK: - Initialization
    init(credentials: APICredentialStore) {
        self.trafficService = TrafficService(credentials: credentials)
    }
    
    // MARK: - Public Methods
    func postMessage(_ message: TrafficMessageRequest, completion: @escaping (Error?) -> Void) {
        
    }
    
}

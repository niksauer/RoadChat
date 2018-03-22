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
    
    // MARK: - Private Properties
    private let trafficService: TrafficService
    
    // MARK: - Initialization
    init(trafficService: TrafficService) {
        self.trafficService = trafficService
    }
    
    // MARK: - Public Methods
    func postMessage(_ message: TrafficMessageRequest, completion: @escaping (Error?) -> Void) {
        
    }
    
}

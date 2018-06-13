//
//  RoadChatAPI.swift
//  RoadChat
//
//  Created by Niklas Sauer on 11.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import NetworkKit

struct RoadChatAPI: APIConfiguration {
    // local: localhost
    // remote: 141.52.39.100
    
    let hostURL: String = "http://141.52.39.100"
    let port: Int? = 8080
    let credentials: APICredentialStore?
    
    init(credentials: APICredentialStore) {
        self.credentials = credentials
    }
}

//
//  TrafficColorPalette.swift
//  RoadChat
//
//  Created by Phillip Rust on 10.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

protocol TrafficColorPalette {
    
    // Background Colors
    var jamBgColor: UIColor { get}
    var accidentBgColor: UIColor { get }
    var dangerBgColor: UIColor { get }
    var detourBgColor: UIColor { get }
    
}


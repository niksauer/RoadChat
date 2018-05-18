//
//  BasicColorPalette.swift
//  RoadChat
//
//  Created by Niklas Sauer on 10.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

protocol BasicColorPalette {
    var backgroundColor: UIColor { get }
    var contentBackgroundColor: UIColor { get }
    var overlayBackgroundColor: UIColor { get }
    var separatorColor: UIColor { get }
    
    var interfaceControlColor: UIColor { get }
    
    var darkTextColor: UIColor { get }
    var lightTextColor: UIColor { get }
    
    var tintColor: UIColor { get }
    
    var destructiveColor: UIColor { get }
    var createColor: UIColor { get }
}

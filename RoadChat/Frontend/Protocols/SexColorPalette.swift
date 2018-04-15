//
//  SexColorPalette.swift
//  RoadChat
//
//  Created by Niklas Sauer on 15.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

protocol SexColorPalette {
    var maleColor: UIColor { get }
    var femaleColor: UIColor { get }
    var otherColor: UIColor { get }
}

//
//  KarmaColorContainer.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

protocol KarmaColorPalette {
    var upvoteBgColor: UIColor { get }
    var upvoteTextColor: UIColor { get }
    
    var neutralBgColor: UIColor { get }
    var neutralTextColor: UIColor { get }
    
    var downvoteBgColor: UIColor { get }
    var downvoteTextColor: UIColor { get }
}

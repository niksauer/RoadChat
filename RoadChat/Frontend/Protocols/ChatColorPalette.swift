//
//  ChatColorPalette.swift
//  RoadChat
//
//  Created by Niklas Sauer on 18.05.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

protocol ChatColorPalette {
    var incomingTextColor: UIColor { get }
    var incomingBubbleColor: UIColor { get }
    var outgoingTextColor: UIColor { get }
    var outgoingBubbleColor: UIColor { get }
}

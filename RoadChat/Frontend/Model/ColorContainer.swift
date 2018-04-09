//
//  ColorContainer.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

struct ColorContainer: KarmaColorPalette {
    // General
    
    // KarmaColorContainer
    let upvoteBgColor = UIColor(displayP3Red: 236/255, green: 104/255, blue: 44/255, alpha: 1)
    let upvoteTextColor = UIColor.white

    let neutralBgColor = UIColor.clear
    let neutralTextColor = UIColor.black

    let downvoteBgColor = UIColor(displayP3Red: 86/255, green: 94/255, blue: 227/255, alpha: 1)
    let downvoteTextColor = UIColor.white
}

//
//  ColorContainer.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

struct ColorContainer: BasicColorPalette, KarmaColorPalette, TrafficColorPalette {

    // General
    let yellow = UIColor(displayP3Red: 243/255, green: 211/255, blue: 93/255, alpha: 1)
    let orange = UIColor(displayP3Red: 240/255, green: 151/255, blue: 71/255, alpha: 1)
    let red = UIColor(displayP3Red: 223/255, green: 82/255, blue: 65/255, alpha: 1)
    let darkOrange = UIColor(displayP3Red: 236/255, green: 104/255, blue: 44/255, alpha: 1)
    let blue = UIColor(displayP3Red: 86/255, green: 94/255, blue: 227/255, alpha: 1)
    let lightGray = UIColor(red: 243/255, green: 242/255, blue: 247/255, alpha: 1)
    
    // BasicColorPalette
    var backgroundColor: UIColor { return lightGray }
    
    // KarmaColorPalette
    var upvoteBgColor: UIColor { return darkOrange }
    let upvoteTextColor = UIColor.white

    let neutralBgColor = UIColor.clear
    let neutralTextColor = UIColor.black

    var downvoteBgColor: UIColor { return blue }
    let downvoteTextColor = UIColor.white
    
    // TrafficColorPalette
    var jamBgColor: UIColor { return yellow }
    var accidentBgColor: UIColor { return orange }
    var dangerBgColor: UIColor { return red }
    var detourBgColor: UIColor { return yellow }
}

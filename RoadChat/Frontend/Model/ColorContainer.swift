//
//  ColorContainer.swift
//  RoadChat
//
//  Created by Niklas Sauer on 09.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

struct ColorContainer: BasicColorPalette, KarmaColorPalette, TrafficColorPalette, SexColorPalette, CarColorPalette, GeofenceColorPalette {
    
    // General
    private let yellow = UIColor(displayP3Red: 243/255, green: 211/255, blue: 93/255, alpha: 1)
    private let red = UIColor(displayP3Red: 223/255, green: 82/255, blue: 65/255, alpha: 1)
    private let orange = UIColor(displayP3Red: 240/255, green: 151/255, blue: 71/255, alpha: 1)
    private let darkOrange = UIColor(displayP3Red: 236/255, green: 104/255, blue: 44/255, alpha: 1)
    private let darkPurple = UIColor(displayP3Red: 86/255, green: 94/255, blue: 227/255, alpha: 1)
    private let lightGray = UIColor(displayP3Red: 243/255, green: 242/255, blue: 247/255, alpha: 1)
    private let darkGrey = UIColor.darkGray
    private let lightBlue = UIColor(displayP3Red: 0, green: 122/255, blue: 1, alpha: 1)
    private let black = UIColor.black
    private let white = UIColor.white
    private let clear = UIColor.clear
    
    // BasicColorPalette
    var backgroundColor: UIColor { return lightGray }
    var controlBackgroundColor: UIColor { return darkGrey.withAlphaComponent(0.6) }
    var contentBackgroundColor: UIColor { return white }
    var textColor: UIColor { return black }
    var lightTextColor: UIColor { return lightGray }
    var tintColor: UIColor { return lightBlue }
    var destructiveColor: UIColor { return red }
    
    // KarmaColorPalette
    var upvoteBgColor: UIColor { return darkOrange }
    var upvoteTextColor: UIColor { return white }

    var neutralBgColor: UIColor { return clear }
    var neutralTextColor: UIColor { return black }

    var downvoteBgColor: UIColor { return darkPurple }
    var downvoteTextColor: UIColor { return white }
    
    // TrafficColorPalette
    var jamBgColor: UIColor { return yellow }
    var accidentBgColor: UIColor { return orange }
    var dangerBgColor: UIColor { return red }
    var detourBgColor: UIColor { return yellow }
    
    // SexColorPalette
    var maleColor: UIColor { return lightBlue }
    var femaleColor: UIColor { return white }
    var otherColor: UIColor { return black }
    
    // CarColorPalette
    var defaultCarColor: UIColor { return yellow }
    
    // CarColorPalette
    var geofenceBackgroundColor: UIColor { return red.withAlphaComponent(0.1) }
    
}

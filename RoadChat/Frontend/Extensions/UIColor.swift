//
//  UIColor.swift
//  RoadChat
//
//  Created by Niklas Sauer on 13.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import UIKit

/// https://www.ralfebert.de/ios-examples/uikit/uicolor-rgb/
extension UIColor {
    convenience init(rgbHex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((rgbHex & 0xff0000) >> 16) / 255
        let g = CGFloat((rgbHex & 0x00ff00) >>  8) / 255
        let b = CGFloat((rgbHex & 0x0000ff)      ) / 255
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// https://gist.github.com/yannickl/16f0ed38f0698d9a8ae7
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}



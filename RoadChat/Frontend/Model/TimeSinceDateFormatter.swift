//
//  TimeSinceDateFormatter.swift
//  RoadChat
//
//  Created by Niklas Sauer on 13.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation

class TimeSinceDateFormatter: DateFormatter {
    override func string(from date: Date) -> String {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = calendar.timeZone
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: Date())
        
        if let years = components.year, years >= 1 {
            return "\(years)y"
        } else if let months = components.month, months >= 1 {
            return "\(months)mo"
        } else if let days = components.day, days >= 1 {
            return "\(days)d"
        } else if let hours = components.hour, hours >= 1 {
            return "\(hours)h"
        } else if let minutes = components.minute, minutes >= 1 {
            return "\(minutes)m"
        } else if let seconds = components.second {
            return "\(seconds)s"
        }
        
        return "future"
    }
}

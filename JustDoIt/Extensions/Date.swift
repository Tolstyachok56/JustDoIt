//
//  Date.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 20.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import Foundation

extension Date {
    
    var zeroSeconds: Date? {
        get {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
            return calendar.date(from: dateComponents)
        }
    }
    
}

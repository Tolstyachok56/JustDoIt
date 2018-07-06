//
//  Item.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 06.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import Foundation

extension Item {
    
    func scheduleNotification() {
        if let dueDate = dueDate, shouldRemind && dueDate > Date() {
            print("We should shedule notification")
        }
    }
    
}

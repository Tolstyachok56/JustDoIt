//
//  Item.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 06.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import Foundation
import UserNotifications

extension Item {
    
    //MARK: - User notifications methods
    
    func scheduleNotification() {
        removeNotification()
        
        if let dueDate = self.dueDate, self.shouldRemind && dueDate > Date() && isChecked == false {
            
            let content = UNMutableNotificationContent()
            content.title = "Reminder:"
            content.body = self.name!
            content.sound = UNNotificationSound.default
            content.badge = 1
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.month, .day, .hour, .minute], from: dueDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: self.uid!, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: nil)
            print("Set notification for itemID \(self.uid!)")
        }
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [self.uid!])
        print("Removed notification for itemID \(self.uid!)")
    }
    
}

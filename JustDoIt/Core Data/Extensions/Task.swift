//
//  Task.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 06.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import Foundation
import UserNotifications

extension Task {
    
    //MARK: - Static properties
    
    static var dueDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
    static var dueTimeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
    //MARK: - User notifications methods
    
    func scheduleNotification() {
        removeNotification()
        
        if let reminderDate = self.reminderDate, self.shouldRemind && reminderDate > Date() && isChecked == false {
            
            let content = UNMutableNotificationContent()
            content.title = (self.list?.name)!
            content.body = self.title!
            content.sound = UNNotificationSound.default()
            content.badge = 1
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.month, .day, .hour, .minute], from: reminderDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: self.uid!, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: nil)
            print("Set notification for taskID \(self.uid!)")
        }
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [self.uid!])
        print("Removed notification for taskID \(self.uid!)")
    }
    
}

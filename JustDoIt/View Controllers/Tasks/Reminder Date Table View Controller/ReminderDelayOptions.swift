//
//  ReminderDelayOptions.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 20.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import Foundation

struct DelayOption {
    let title: String
    let component: Calendar.Component
    let value: Int
}

struct Reminder {
    static let delayOptions: [DelayOption] = [DelayOption(title: "At due date", component: .minute, value: 0),
                                              DelayOption(title: "5 min before", component: .minute, value: -5),
                                              DelayOption(title: "15 min before", component: .minute, value: -15),
                                              DelayOption(title: "30 min before", component: .minute, value: -30),
                                              DelayOption(title: "1 hour before", component: .hour, value: -1),
                                              DelayOption(title: "2 hours before", component: .hour, value: -2),
                                              DelayOption(title: "1 day before", component: .day, value: -1),
                                              DelayOption(title: "2 days before", component: .day, value: -2),
                                              DelayOption(title: "1 week before", component: .day, value: -7)]
    
    static func getDelayOption(withTitle title: String) -> DelayOption? {
        let delayOption = delayOptions.filter { $0.title == title }
        if let option = delayOption.first {
            return option
        }
        return nil
    }
    
}

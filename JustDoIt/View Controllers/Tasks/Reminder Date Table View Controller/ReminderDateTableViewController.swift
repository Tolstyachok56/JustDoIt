//
//  ReminderDateTableViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 20.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import UserNotifications

struct DelayOption {
    let title: String
    let component: Calendar.Component
    let value: Int
}

struct Reminder {
    static let delayOptions: [DelayOption] = [DelayOption(title: "at due date", component: .minute, value: 0),
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

protocol ReminderDateTableViewControllerDelegate {
    func controller(_ controller: ReminderDateTableViewController, didPick reminderDelay: String?)
}

class ReminderDateTableViewController: UITableViewController {
    
    // MARK: -
    
    var delegate: ReminderDateTableViewControllerDelegate?
    
    // MARK: -
    
    var reminderDelay: String? = nil
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Remind", comment: "Remind")
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.controller(self, didPick: reminderDelay)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return Reminder.delayOptions.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderDateTableViewCell.reuseIdentifier, for: indexPath) as! ReminderDateTableViewCell
        
        if indexPath.section == 0 {
            cell.delayOptionLabel.text = "None"
        } else {
            let title = Reminder.delayOptions[indexPath.row].title
            cell.delayOptionLabel.text = NSLocalizedString(title, comment: title)
            if let reminderDelay = self.reminderDelay, reminderDelay == title {
                cell.accessoryType = .checkmark
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1  {
            let delayOption = Reminder.delayOptions[indexPath.row]
            self.reminderDelay = delayOption.title
        } else {
            self.reminderDelay = nil
        }
        
        _ = navigationController?.popViewController(animated: true)
    }

}

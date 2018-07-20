//
//  ReminderDateTableViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 20.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class ReminderDateTableViewController: UITableViewController {
    
    // MARK: -
    
    var task: Task?
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Remind", comment: "Remind")
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
            if let reminderDelay = task?.reminderDelay, reminderDelay == title {
                cell.accessoryType = .checkmark
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let dueDate = task?.dueDate, indexPath.section == 1  {
            let delayOption = Reminder.delayOptions[indexPath.row]
            task?.shouldRemind = true
            task?.reminderDate = Calendar.current.date(byAdding: delayOption.component, value: delayOption.value, to: dueDate)
            task?.reminderDelay = delayOption.title
        } else {
            task?.shouldRemind = false
            task?.reminderDate = nil
            task?.reminderDelay = nil
        }
        
        _ = navigationController?.popViewController(animated: true)
    }

}

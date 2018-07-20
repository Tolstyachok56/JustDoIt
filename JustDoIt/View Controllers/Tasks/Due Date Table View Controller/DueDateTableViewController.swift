//
//  DueDateTableViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 20.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class DueDateTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    // MARK: -
    
    var task: Task?
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Due Date", comment: "Due Date")
        
        setupView()
    }
    
    
    // MARK: - View methods
    
    private func setupView() {
        setupDueDatePicker()
    }
    
    private func setupDueDatePicker() {
        guard let dueDate = task?.dueDate else {
            dueDatePicker.date = Date().zeroSeconds!
            return
        }
        dueDatePicker.date = dueDate
    }
    
    // MARK: - Actions
    
    @IBAction private func dueDateChanged(_ sender: UIDatePicker) {
        task?.dueDate = sender.date
        if task?.shouldRemind == true, let delayOption = Reminder.getDelayOption(withTitle: (task?.reminderDelay)!) {
            task?.reminderDate = Calendar.current.date(byAdding: delayOption.component, value: delayOption.value, to: sender.date)
        }
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            task?.dueDate = nil
            task?.shouldRemind = false
            task?.reminderDate = nil
            task?.reminderDelay = nil
            _ = navigationController?.popViewController(animated: true)
        }
    }

}

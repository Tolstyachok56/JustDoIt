//
//  TaskTableViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 18.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import UserNotifications

class TaskTableViewController: UITableViewController {
    
    // MARK: - Segues
    
    private enum Segue {
        static let DueDate = "DueDate"
        static let ReminderDate = "ReminderDate"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var reminderDateLabel: UILabel!
    
    // MARK: -
    
    var task: Task?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Edit Task", comment: "Edit Task")
        
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let title = titleTextField.text, !title.isEmpty {
            task?.title = title
        }
        
        task?.scheduleNotification()
    }
    
    // MARK: - View methods
    
    private func setupView() {
        setupBarButtonItems()
        setupTitleTextField()
        setupDueDateLabel()
        setupReminderDateLabel()
    }
    
    private func setupBarButtonItems() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func setupTitleTextField() {
        titleTextField.text = task?.title
    }
    
    private func setupDueDateLabel() {
        updateDueDateLabel()
    }
    
    private func setupReminderDateLabel() {
        updateReminderDateLabel()
    }
    
    //update
    
    private func updateDueDateLabel() {
        guard let dueDate = task?.dueDate else {
            dueDateLabel.text = NSLocalizedString("No due date", comment: "No due date")
            return
        }
        dueDateLabel.text = Task.dueDateFormatter.string(from: dueDate)
    }
    
    private func updateReminderDateLabel() {
        if let _ = task?.dueDate {
            reminderDateLabel.textColor = .darkGray
        } else {
            reminderDateLabel.textColor = .lightGray
        }
        
        guard let _ = task?.reminderDate, let reminderDelay = task?.reminderDelay  else {
            reminderDateLabel.text = NSLocalizedString("No reminder date", comment: "No reminder date")
            return
        }
        reminderDateLabel.text = NSLocalizedString(reminderDelay, comment: reminderDelay)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.DueDate:
            guard let destination = segue.destination as? DueDateTableViewController else { return }
            destination.delegate = self
            destination.dueDate = task?.dueDate
        case Segue.ReminderDate:
            guard let destination = segue.destination as? ReminderDateTableViewController else { return }
            destination.delegate = self
            destination.reminderDelay = task?.reminderDelay
        default:
            fatalError("Unexpected segue identifier")
        }
    }
    
    // MARK: - UITableViewDataSource methods
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Title", comment: "Title")
        } else {
            return ""
        }
    }
    
    // MARK: - UITableViewDelegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            titleTextField.resignFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath == IndexPath(row: 1, section: 1) && task?.dueDate == nil {
            return nil
        }
        return indexPath
    }
    
}

// MARK: - UITextFieldDelegate methods

extension TaskTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
}

// MARK: - DueDateTableViewControllerDelegate methods

extension TaskTableViewController: DueDateTableViewControllerDelegate {
    
    func controller(_ controller: DueDateTableViewController, didPick date: Date?) {
        
        if let dueDate = date {
            task?.dueDate = dueDate
            if task?.shouldRemind == true, let delayOption = Reminder.getDelayOption(withTitle: (task?.reminderDelay)!) {
                task?.reminderDate = Calendar.current.date(byAdding: delayOption.component, value: delayOption.value, to: dueDate)
            }
        } else {
            task?.dueDate = nil
            task?.shouldRemind = false
            task?.reminderDate = nil
            task?.reminderDelay = nil
        }
        
        updateDueDateLabel()
        updateReminderDateLabel()
    }
    
}

// MARK: - ReminderDateTableViewControllerDelegate methods

extension TaskTableViewController: ReminderDateTableViewControllerDelegate {
    
    func controller(_ controller: ReminderDateTableViewController, didPick reminderDelay: String?) {
        if let reminderDelay = reminderDelay, let dueDate = task?.dueDate,
            let delayOption = Reminder.getDelayOption(withTitle: reminderDelay) {
            task?.shouldRemind = true
            task?.reminderDate = Calendar.current.date(byAdding: delayOption.component, value: delayOption.value, to: dueDate)
            task?.reminderDelay = reminderDelay
        } else {
            task?.shouldRemind = false
            task?.reminderDate = nil
            task?.reminderDelay = nil
        }
        
        updateReminderDateLabel()
    }
    
}

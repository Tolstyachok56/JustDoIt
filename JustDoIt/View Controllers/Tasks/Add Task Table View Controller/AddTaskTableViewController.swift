//
//  AddTaskTableViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 18.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import UserNotifications

class AddTaskTableViewController: UITableViewController {
    
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
    
    var list: List?
    
    // MARK: -
    
    var dueDate: Date? = nil
    var shouldRemind: Bool = false
    var reminderDate: Date? = nil
    var reminderDelay: String? = nil
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Add Task", comment: "Add Task")
        
        setupView()
    }
    
    // MARK: - View methods
    
    private func setupView() {
        setupBarButtonItems()
        setupTitleTextField()
        setupDueDateLabel()
        setupReminderDateLabel()
    }
    
    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
        
    }
    
    private func setupTitleTextField() {
        titleTextField.becomeFirstResponder()
    }

    private func setupDueDateLabel() {
        updateDueDateLabel()
    }
    
    private func setupReminderDateLabel() {
        updateReminderDateLabel()
    }
    
    //update
    
    private func updateDueDateLabel() {
        guard let dueDate = self.dueDate else {
            dueDateLabel.text = NSLocalizedString("No due date", comment: "No due date")
            return
        }
        dueDateLabel.text = Task.dueDateFormatter.string(from: dueDate)
    }
    
    private func updateReminderDateLabel() {
        guard let _ = self.reminderDate, let reminderDelay = self.reminderDelay  else {
            reminderDateLabel.text = NSLocalizedString("No reminder date", comment: "No reminder date")
            return
        }
        reminderDateLabel.text = NSLocalizedString(reminderDelay, comment: reminderDelay)
    }
    
    // MARK: - Actions
    
    @objc private func save(_ sender: UIBarButtonItem) {
        guard let managedObjectContext = list?.managedObjectContext else { return }
        
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(withTitle: NSLocalizedString("Title missing", comment: "Title missing"), andMessage: NSLocalizedString("Your task doesn't have any title", comment: "Your task doesn't have any title"))
            return
        }
        
        let task = Task(context: managedObjectContext)
        
        task.title = title
        task.isChecked = false
        task.shouldRemind = shouldRemind
        task.dueDate = dueDate
        task.uid = UUID().uuidString
        task.createdDate = Date()
        task.reminderDate = reminderDate
        task.reminderDelay = reminderDelay
        list?.addToTasks(task)
        
        task.scheduleNotification()
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.DueDate:
            guard let destination = segue.destination as? DueDateTableViewController else { return }
            destination.delegate = self
        case Segue.ReminderDate:
            guard let destination = segue.destination as? ReminderDateTableViewController else { return }
            destination.delegate = self
        default:
            fatalError("Unexpected segue identifier")
        }
    }

    // MARK: - UITableViewDelegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            titleTextField.resignFirstResponder()
        }
    }

}

// MARK: - UITextFieldDelegate methods

extension AddTaskTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
}

// MARK: - DueDateTableViewControllerDelegate methods

extension AddTaskTableViewController: DueDateTableViewControllerDelegate {
    
    func controller(_ controller: DueDateTableViewController, didPick date: Date?) {
        if let dueDate = date {
            self.dueDate = dueDate
            if self.shouldRemind == true, let delayOption = Reminder.getDelayOption(withTitle: (self.reminderDelay)!) {
                self.reminderDate = Calendar.current.date(byAdding: delayOption.component, value: delayOption.value, to: dueDate)
            }
        } else {
            self.dueDate = nil
            self.shouldRemind = false
            self.reminderDate = nil
            self.reminderDelay = nil
        }
        
        updateDueDateLabel()
        updateReminderDateLabel()
    }
    
}

// MARK: - ReminderDateTableViewControllerDelegate methods

extension AddTaskTableViewController: ReminderDateTableViewControllerDelegate {
    
    func controller(_ controller: ReminderDateTableViewController, didPick reminderDelay: String?) {
        if let reminderDelay = reminderDelay, let dueDate = self.dueDate,
            let delayOption = Reminder.getDelayOption(withTitle: reminderDelay) {
            self.shouldRemind = true
            self.reminderDate = Calendar.current.date(byAdding: delayOption.component, value: delayOption.value, to: dueDate)
            self.reminderDelay = reminderDelay
        } else {
            self.shouldRemind = false
            self.reminderDate = nil
            self.reminderDelay = nil
        }
        
        updateReminderDateLabel()
    }
    
}

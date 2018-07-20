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
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in })
        
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let title = titleTextField.text, !title.isEmpty {
            task?.title = title
        }
        
        task?.scheduleNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDueDateLabel()
        updateReminderDateLabel()
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
            dueDateLabel.text = "None"
            return
        }
        dueDateLabel.text = Task.dueDateFormatter.string(from: dueDate)
    }
    
    private func updateReminderDateLabel() {
        guard let _ = task?.reminderDate, let reminderDelay = task?.reminderDelay  else {
            reminderDateLabel.text = "None"
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
            destination.task = task
        case Segue.ReminderDate:
            guard let destination = segue.destination as? ReminderDateTableViewController else { return }
            destination.task = task
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

extension TaskTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
}

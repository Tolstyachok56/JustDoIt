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
    
    // MARK: - Properties
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateButton: UIButton!
    @IBOutlet weak var dueDatePickerCell: UITableViewCell!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    
    // MARK: -
    var dueDatePickerVisible = false
    let dueDatePickerIndexPath = IndexPath(row: 2, section: 1)
    
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
        setupTitleTextField()
        setupShouldRemindSwitch()
        setupDueDateButton()
        setupDueDatePicker()
    }
    
    private func setupTitleTextField() {
        titleTextField.text = task?.title
    }
    
    private func setupShouldRemindSwitch() {
        guard let shouldRemind = task?.shouldRemind else {
            shouldRemindSwitch.isOn = false
            return
        }
        shouldRemindSwitch.isOn = shouldRemind
    }
    
    private func setupDueDateButton() {
        updateDueDateButton()
    }
    
    private func setupDueDatePicker() {
        if let dueDate = task?.dueDate {
            dueDatePicker.date = dueDate
        }
    }
    
    //update
    
    private func updateDueDateButton() {
        guard let dueDate = task?.dueDate else {
            dueDateButton.setTitle(Task.dueDateFormatter.string(from: Date()), for: .normal)
            return
        }
        dueDateButton.setTitle(Task.dueDateFormatter.string(from: dueDate), for: .normal)
    }
    
    private func showDueDatePicker(_ show: Bool) {
        if dueDatePickerVisible != show {
            dueDatePickerVisible = show
            
            if dueDatePickerVisible {
                tableView.insertRows(at: [dueDatePickerIndexPath], with: .fade)
            } else {
                tableView.deleteRows(at: [dueDatePickerIndexPath], with: .fade)
            }
        }
    }

    // MARK: - Actions
    
    @IBAction private func toggleShouldRemindSwitch(_ sender: UISwitch) {
        titleTextField.resignFirstResponder()
        
        task?.shouldRemind = sender.isOn
        
        if shouldRemindSwitch.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in })
        }
    }
    
    @IBAction private func dueDateButtonPressed(_ sender: UIButton) {
        titleTextField.resignFirstResponder()
        showDueDatePicker(!dueDatePickerVisible)
    }
    
    @IBAction private func dueDateChanged(_ sender: UIDatePicker) {
        task?.dueDate = sender.date
        updateDueDateButton()
    }
    
    // MARK: - UITableViewDataSource methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == dueDatePickerIndexPath.section && dueDatePickerVisible {
            return 3
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == dueDatePickerIndexPath {
            return dueDatePickerCell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    // MARK: - UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == dueDatePickerIndexPath {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath == dueDatePickerIndexPath {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
}

// MARK: - UITextFieldDelegate methods

extension TaskTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showDueDatePicker(false)
    }
    
}

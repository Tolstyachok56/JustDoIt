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
    
    var list: List?
    
//    var task: Task?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Task"
        
        setupView()
    }
    
    // MARK: - View methods
    
    private func setupView() {
        setupTitleTextField()
        setupBarButtonItems()
        setupShouldRemindSwitch()
        setupDueDateButton()
        setupDueDatePicker()
    }
    
    private func setupTitleTextField() {
        titleTextField.becomeFirstResponder()
    }
    
    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
    }
    
    private func setupShouldRemindSwitch() {
        shouldRemindSwitch.isOn = false
    }
    
    private func setupDueDateButton() {
        dueDateButton.setTitle(Task.dueDateFormatter.string(from: Date()), for: .normal)
    }
    
    private func setupDueDatePicker() {
        dueDatePicker.date = Date()
    }
    
    //update
    
    private func updateDueDateButton() {
        dueDateButton.setTitle(Task.dueDateFormatter.string(from: dueDatePicker.date), for: .normal)
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
    
    @objc private func save(_ sender: UIBarButtonItem) {
        guard let managedObjectContext = list?.managedObjectContext else { return }
        
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(withTitle: "Name missing", andMessage: "Your task doesn't have any title")
            return
        }
        
        let task = Task(context: managedObjectContext)
        
        task.title = title
        task.isChecked = false
        task.shouldRemind = shouldRemindSwitch.isOn
        task.dueDate = dueDatePicker.date
        task.uid = UUID().uuidString
        task.createdDate = Date()
        list?.addToTasks(task)
        
        task.scheduleNotification()
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func toggleShouldRemindSwitch(_ sender: UISwitch) {
        titleTextField.resignFirstResponder()
        
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

extension AddTaskTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showDueDatePicker(false)
    }
    
}

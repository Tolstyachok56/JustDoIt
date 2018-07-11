//
//  AddTaskViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class AddTaskViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var shouldRemindSwitch: UISwitch!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dueDateButton: UIButton!
    
    //MARK: -
    
    var list: List?
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Task"
        
        setupView()
    }
    
    //MARK: - View methods
    
    //setup
    
    private func setupView() {
        setupBarButtonItems()
        setupShouldRemindSwitch()
        setupDatePicker()
        setupDueDateButton()
    }
    
    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
    }
    
    private func setupShouldRemindSwitch() {
        shouldRemindSwitch.isOn = false
    }
    
    private func setupDueDateButton() {
        updateDueDateButton()
    }
    
    private func setupDatePicker() {
        datePicker.date = Date()
        datePicker.isHidden = true
    }
    
    //update
    
    private func updateDueDateButton() {
        dueDateButton.setTitle(Task.dueDateFormatter.string(from: datePicker.date), for: .normal)
        dueDateButton.isEnabled = shouldRemindSwitch.isOn
    }
        
    //MARK: - Actions
    
    @objc private func save(_ sender: UIBarButtonItem) {
        guard let managedObjectContext = list?.managedObjectContext else { return }
        
        guard let title = nameTextField.text, !title.isEmpty else {
            showAlert(withTitle: "Name missing", andMessage: "Your task doesn't have any title")
            return
        }
        
        let task = Task(context: managedObjectContext)
        
        task.title = title
        task.isChecked = false
        task.shouldRemind = shouldRemindSwitch.isOn
        task.dueDate = datePicker.date
        task.uid = UUID().uuidString
        task.createdDate = Date()
        list?.addToTasks(task)
        
        task.scheduleNotification()
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func toggleShouldRemindSwitch(_ sender: UISwitch) {
        nameTextField.resignFirstResponder()

        updateDueDateButton()
        
        if shouldRemindSwitch.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound], completionHandler: { granted, error in })
        }
    }
    
    @IBAction private func dueDateChanged(_ sender: UIDatePicker) {
        updateDueDateButton()
    }
    
    @IBAction func dueDateButtonPressed(_ sender: UIButton) {
        datePicker.isHidden = !datePicker.isHidden
    }
    
}

//MARK: - UITextFieldDelegate methods

extension AddTaskViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        datePicker.isHidden = true
    }
    
}

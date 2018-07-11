//
//  TaskViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import UserNotifications

class TaskViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var shouldRemindSwitch: UISwitch!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dueDateButton: UIButton!
    
    //MARK: -
    
    var task: Task?
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Task"
        
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let title = nameTextField.text, !title.isEmpty {
            task?.title = title
        }
        
        task?.scheduleNotification()
        
    }
    
    //MARK: - View methods
    
    //setup
    
    private func setupView() {
        setupNameTextField()
        setupShouldRemindSwitch()
        setupDueDateButton()
        setupDatePicker()
    }
    
    private func setupNameTextField() {
        nameTextField.text = task?.title
    }
    
    private func setupShouldRemindSwitch() {
        updateShouldRemindSwitch()
    }
    
    private func setupDueDateButton() {
        updateDueDateButton()
    }
    
    private func setupDatePicker() {
        if let dueDate = task?.dueDate {
            datePicker.date = dueDate
        }
        datePicker.isHidden = true
    }
    
    //update
    
    private func updateShouldRemindSwitch() {
        guard let shouldRemind = task?.shouldRemind else {
            shouldRemindSwitch.isOn = false
            return
        }
        shouldRemindSwitch.isOn = shouldRemind
    }
    
    private func updateDueDateButton() {
        dueDateButton.isEnabled = shouldRemindSwitch.isOn
        
        guard let dueDate = task?.dueDate else {
            dueDateButton.setTitle(Task.dueDateFormatter.string(from: Date()), for: .normal)
            return
        }
        dueDateButton.setTitle(Task.dueDateFormatter.string(from: dueDate), for: .normal)
    }
    
    private func updateDatePicker() {
        guard let shouldRemind = task?.shouldRemind else {
            datePicker.isHidden = true
            return
        }
        datePicker.isHidden = !shouldRemind
    }
    
    //MARK: - Actions
    
    @IBAction private func toggleShouldRemindSwitch(_ sender: UISwitch) {
        nameTextField.resignFirstResponder()
        
        task?.shouldRemind = sender.isOn
        updateDueDateButton()
        
        if shouldRemindSwitch.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in })
        }
    }
    
    @IBAction private func dueDateChanged(_ sender: UIDatePicker) {
        task?.dueDate = sender.date
        updateDueDateButton()
    }
    
    @IBAction private func dueDateButtonPressed(_ sender: UIButton) {
        datePicker.isHidden = !datePicker.isHidden
    }
    
}

//MARK: - UITextFieldDelegate methods

extension TaskViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        datePicker.isHidden = true
    }
    
}

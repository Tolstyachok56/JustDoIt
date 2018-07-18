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
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var dueDateButton: UIButton!
    
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
        
        if let title = titleTextField.text, !title.isEmpty {
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
        titleTextField.text = task?.title
    }
    
    private func setupShouldRemindSwitch() {
        updateShouldRemindSwitch()
    }
    
    private func setupDueDateButton() {
        updateDueDateButton()
    }
    
    private func setupDatePicker() {
        if let dueDate = task?.dueDate {
            dueDatePicker.date = dueDate
        }
        dueDatePicker.isHidden = true
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
            dueDatePicker.isHidden = true
            return
        }
        dueDatePicker.isHidden = !shouldRemind
    }
    
    //MARK: - Actions
    
    @IBAction private func toggleShouldRemindSwitch(_ sender: UISwitch) {
        titleTextField.resignFirstResponder()
        
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
        dueDatePicker.isHidden = !dueDatePicker.isHidden
    }
    
}

//MARK: - UITextFieldDelegate methods

extension TaskViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dueDatePicker.isHidden = true
    }
    
}

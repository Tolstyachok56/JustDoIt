//
//  ItemViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import UserNotifications

class ItemViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var shouldRemindSwitch: UISwitch!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    
    //MARK: -
    
    var item: Item?
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Item"
        
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let name = nameTextField.text, !name.isEmpty {
            item?.name = name
        }
        
        item?.scheduleNotification()
        
    }
    
    //MARK: - View methods
    
    private func setupView() {
        setupNameTextField()
        setupShouldRemindSwitch()
        setupDueDateLabel()
        setupDatePicker()
    }
    
    private func setupNameTextField() {
        nameTextField.text = item?.name
    }
    
    private func setupShouldRemindSwitch() {
        updateShouldRemindSwitch()
    }
    
    private func setupDueDateLabel() {
        updateDueDateLabel()
    }
    
    private func setupDatePicker() {
        if let dueDate = item?.dueDate {
            datePicker.date = dueDate
        }
        updateDatePicker()
    }
    
    private func updateShouldRemindSwitch() {
        guard let shouldRemind = item?.shouldRemind else {
            shouldRemindSwitch.isOn = false
            return
        }
        shouldRemindSwitch.isOn = shouldRemind
    }
    
    private func updateDueDateLabel() {
        guard let dueDate = item?.dueDate else {
            let now = Date()
            dueDateLabel.text = Item.dueDateFormatter.string(from: now)
            return
        }
        dueDateLabel.text = Item.dueDateFormatter.string(from: dueDate)
    }
    
    private func updateDatePicker() {
        guard let shouldRemind = item?.shouldRemind else {
            datePicker.isHidden = true
            return
        }
        datePicker.isHidden = !shouldRemind
    }
    
    //MARK: - Actions
    
    @IBAction func toggleShouldRemindSwitch(_ sender: UISwitch) {
        nameTextField.resignFirstResponder()
        item?.shouldRemind = sender.isOn
        updateDatePicker()
        if shouldRemindSwitch.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound], completionHandler: { granted, error in })
        }
    }
    
    @IBAction func dueDateChanged(_ sender: UIDatePicker) {
        item?.dueDate = sender.date
        updateDueDateLabel()
    }
    
}

//MARK: - UITextFieldDelegate methods

extension ItemViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
}

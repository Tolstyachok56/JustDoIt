//
//  AddItemViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class AddItemViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var shouldRemindSwitch: UISwitch!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    
    //MARK: -
    
    var list: List?
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Item"
        
        setupView()
    }
    
    //MARK: - View methods
    
    private func setupView() {
        setupBarButtonItems()
        setupShouldRemindSwitch()
        setupDueDateLabel()
        setupDatePicker()
    }
    
    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
    }
    
    private func setupShouldRemindSwitch() {
        shouldRemindSwitch.isOn = false
    }
    
    private func setupDueDateLabel() {
        dueDateLabel.text = Item.dueDateFormatter.string(from: Date())
    }
    
    private func setupDatePicker() {
        datePicker.date = Date()
        updateDatePicker()
    }
    
    private func updateDueDateLabel() {
        let dueDate = datePicker.date
        dueDateLabel.text = Item.dueDateFormatter.string(from: dueDate)
    }
    
    private func updateDatePicker() {
        datePicker.isHidden = !shouldRemindSwitch.isOn
    }
    
    //MARK: - Actions
    
    @objc private func save(_ sender: UIBarButtonItem) {
        guard let managedObjectContext = list?.managedObjectContext else { return }
        
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(withTitle: "Name missing", andMessage: "Your item doesn't have any name")
            return
        }
        
        let item = Item(context: managedObjectContext)
        
        item.name = name
        item.isChecked = false
        item.shouldRemind = shouldRemindSwitch.isOn
        item.dueDate = datePicker.date
        item.uid = UUID().uuidString
        item.createdDate = Date()
        list?.addToItems(item)
        
        item.scheduleNotification()
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func toggleShouldRemindSwitch(_ sender: UISwitch) {
        nameTextField.resignFirstResponder()
        updateDatePicker()
        if shouldRemindSwitch.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound], completionHandler: { granted, error in })
        }
    }
    
    @IBAction func dueDateChanged(_ sender: UIDatePicker) {
        updateDueDateLabel()
    }

}

//MARK: - UITextFieldDelegate methods

extension AddItemViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
}

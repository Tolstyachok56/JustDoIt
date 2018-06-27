//
//  ItemViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var shouldRemindSwitch: UISwitch!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    
    //MARK: -
    
    var item: Item?
    
    //MARK: -
    
    var dueDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, YYYY HH:mm"
        return dateFormatter
    }
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Item"
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let name = nameTextField.text, !name.isEmpty {
            item?.name = name
        }
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
            dueDateLabel.text = dueDateFormatter.string(from: now)
            return
        }
        dueDateLabel.text = dueDateFormatter.string(from: dueDate)
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
        item?.shouldRemind = sender.isOn
        updateDatePicker()
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

//
//  DueDateTableViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 20.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class DueDateTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    // MARK: -
    
    var task: Task?
    
    // MARK: - View life cyrcle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Due Date", comment: "Due Date")
        
        setupView()
    }
    
    // MARK: - View methods
    
    private func setupView() {
        setupDueDatePicker()
    }
    
    private func setupDueDatePicker() {
        guard let dueDate = task?.dueDate else {
            dueDatePicker.date = Date()
            return
        }
        dueDatePicker.date = dueDate
    }
    
    // MARK: - Actions
    
    @IBAction private func dueDateChanged(_ sender: UIDatePicker) {
        task?.dueDate = sender.date
        task?.shouldRemind = true
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            task?.shouldRemind = false
            task?.dueDate = nil
            _ = navigationController?.popViewController(animated: true)
        }
    }

}

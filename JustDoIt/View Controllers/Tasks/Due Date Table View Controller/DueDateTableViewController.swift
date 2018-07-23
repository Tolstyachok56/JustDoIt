//
//  DueDateTableViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 20.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

protocol DueDateTableViewControllerDelegate {
    func controller(_ controller: DueDateTableViewController, didPick date: Date?)
}

class DueDateTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    // MARK: -
    
    var delegate: DueDateTableViewControllerDelegate?
    
    // MARK: -
    
    var dueDate: Date?
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Due Date", comment: "Due Date")
        
        setupView()
        
        dueDate = dueDatePicker.date
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.controller(self, didPick: dueDate)
    }
    
    // MARK: - View methods
    
    private func setupView() {
        setupDueDatePicker()
    }
    
    private func setupDueDatePicker() {
        guard let dueDate = self.dueDate else {
            dueDatePicker.date = Date().zeroSeconds!
            return
        }
        dueDatePicker.date = dueDate
    }
    
    // MARK: - Actions
    
    @IBAction private func dueDateChanged(_ sender: UIDatePicker) {
        dueDate = sender.date
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                dueDate = nil
            } else if indexPath.row == 1 {
                let today = Date()
                dueDate = Calendar.current.startOfDay(for: today)
            } else if indexPath.row == 2 {
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                dueDate = Calendar.current.startOfDay(for: tomorrow!)
            }
            _ = navigationController?.popViewController(animated: true)
        }
    }

}

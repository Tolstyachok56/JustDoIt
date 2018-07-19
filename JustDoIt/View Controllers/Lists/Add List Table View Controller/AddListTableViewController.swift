//
//  AddListTableViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 19.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import CoreData

class AddListTableViewController: UITableViewController {
    
    //MARK: - Segues
    
    private enum Segue {
        static let Icon = "Icon"
    }
    
    //MARK: - Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var iconImageView: UIImageView!
    
    //MARK: -
    
    var managedObjectContext: NSManagedObjectContext?
    
    //MARK: -
    
    var iconName: String = "NoIcon"
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Add List", comment: "AddListTableViewController title")
        
        setupView()
    }
    
    // MARK: - View methods
    
    //setup
    private func setupView() {
        setupIconImageView()
        setupNameTextField()
    }
    
    private func setupNameTextField() {
        nameTextField.becomeFirstResponder()
    }
    
    private func setupIconImageView() {
        updateIconImageView()
    }
    
    //update
    private func updateIconImageView() {
        iconImageView.image = UIImage(named: iconName)
    }
    
    //MARK: - Actions
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let managedObjectContext = managedObjectContext else { return }
        
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(withTitle: NSLocalizedString("Name missing", comment: "Alert title"), andMessage: NSLocalizedString("Your list doesn't have any name", comment: "Alert message"))
            return
        }
        
        let list = List(context: managedObjectContext)
        
        list.name = name
        list.iconName = self.iconName
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.Icon:
            guard let destination = segue.destination as? IconViewController else { return }
            destination.delegate = self
            destination.iconName = self.iconName
        default:
            fatalError("Unexpected segue identifier")
        }
    }
    
    // MARK: - UITableViewDelegate
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nameTextField.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == IndexPath(row: 1, section: 1) {
            performSegue(withIdentifier: Segue.Icon, sender: indexPath)
        }
    }

}

//MARK: - UITextFieldDelegate methods

extension AddListTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
}

//MARK: - IconViewControllerDelegate methods

extension AddListTableViewController: IconViewControllerDelegate {
    
    func controller(_ controller: IconViewController, didPick iconName: String) {
        self.iconName = iconName
        updateIconImageView()
    }
    
}

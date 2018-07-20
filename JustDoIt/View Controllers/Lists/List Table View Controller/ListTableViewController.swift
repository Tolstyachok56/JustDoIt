//
//  ListTableViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 19.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    //MARK: - Segues
    
    private enum Segue {
        static let Icon = "Icon"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var iconImageView: UIImageView!
    
    // MARK: -

    var list: List?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title =  NSLocalizedString("Edit List", comment: "ListTableViewController title")
        
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let name = nameTextField.text, !name.isEmpty {
            list?.name = name
        }
    }
    
    // MARK: - View methods
    
    //setup
    private func setupView() {
        setupNameTextField()
        setupIconImageView()
        setupBarButtonItems()
    }
    
    private func setupNameTextField() {
        nameTextField.text = list?.name
    }
    
    private func setupIconImageView() {
        updateIconImageView()
    }
    
    private func setupBarButtonItems() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    //update
    private func updateIconImageView() {
        if let iconName = list?.iconName {
            iconImageView.image = UIImage(named: iconName)
        } else {
            iconImageView.image = UIImage(named: "NoIcon")
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.Icon:
            guard let destination = segue.destination as? IconViewController else { return }
            destination.delegate = self
            destination.iconName = list?.iconName
        default:
            fatalError("Unexpected segue identifier")
        }
    }
    
    // MARK: - UITableViewDelegate methods
    
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

extension ListTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
}

//MARK: - IconViewControllerDelegate methods

extension ListTableViewController: IconViewControllerDelegate {
    
    func controller(_ controller: IconViewController, didPick iconName: String) {
        list?.iconName = iconName
        updateIconImageView()
    }
    
}

//
//  AddListViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import CoreData

class AddListViewController: UIViewController {
    
    //MARK: - Segues
    
    private enum Segue {
        static let Icon = "Icon"
    }
    
    //MARK: - Properties
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var iconImageView: UIImageView!
    
    //MARK: -
    
    var managedObjectContext: NSManagedObjectContext?
    
    var iconName: String = "NoIcon"
    
    //MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add List"
        
        setupView()
    }
    
    //MARK: - View methods
    
    private func setupView() {
        setupIconImageView()
    }
    
    private func setupIconImageView() {
        iconImageView.layer.borderWidth = CGFloat(1.0)
        iconImageView.layer.cornerRadius = CGFloat(5)
        
        updateIconImageView()
    }
    
    private func updateIconImageView() {
        iconImageView.image = UIImage(named: iconName)
    }
    
    //MARK: - Actions
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let managedObjectContext = managedObjectContext else { return }
        
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(withTitle: "Name missing", andMessage: "Your list doesn't have any name")
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

}

//MARK: - UITextFieldDelegate methods

extension AddListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
}

//MARK: - IconViewControllerDelegate methods

extension AddListViewController: IconViewControllerDelegate {
    
    func controller(_ controller: IconViewController, didPick iconName: String) {
        self.iconName = iconName
        updateIconImageView()
    }
    
}

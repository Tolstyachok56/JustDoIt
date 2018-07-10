//
//  ListViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    //MARK: - Segues
    
    private enum Segue {
        static let Icon = "Icon"
    }
    
    //MARK: - Properties
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var iconImageView: UIImageView!
    
    //MARK: -
    
    var list: List?
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit List"
        
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let name = nameTextField.text, !name.isEmpty {
            list?.name = name
        }
    }
    
    //MARK: - View methods
    
    private func setupView() {
        setupNameTextField()
        setupIconImageView()
    }
    
    private func setupNameTextField() {
        nameTextField.text = list?.name
    }
    
    private func setupIconImageView() {
        iconImageView.layer.borderWidth = CGFloat(0.25)
        iconImageView.layer.cornerRadius = CGFloat(5.0)
        iconImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        updateIconImageView()
    }
    
    private func updateIconImageView() {
        if let iconName = list?.iconName {
            iconImageView.image = UIImage(named: iconName)
        } else {
            iconImageView.image = UIImage(named: "NoIcon")
        }
    }
    
    //MARK: - Navigation
    
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
    
}

//MARK: - UITextFieldDelegate methods

extension ListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
}

//MARK: - IconViewControllerDelegate methods

extension ListViewController: IconViewControllerDelegate {
    
    func controller(_ controller: IconViewController, didPick iconName: String) {
        list?.iconName = iconName
        updateIconImageView()
    }
    
}

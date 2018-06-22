//
//  AddItemViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import  CoreData

class AddItemViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet var nameTextField: UITextField!

    //MARK: -
    
    var list: List?
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add List"
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    //MARK: - View methods
    
    private func setupView() {
        setupBarButtonItems()
    }
    
    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
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
        list?.addToItems(item)
        
        _ = navigationController?.popViewController(animated: true)
    }

}

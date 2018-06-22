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
    
    //MARK: - Properties
    
    @IBOutlet var nameTextField: UITextField!
    
    //MARK: -
    
    var managedObjectContext: NSManagedObjectContext?
    
    //MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add List"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameTextField.becomeFirstResponder()
    }
    
    //MARK: - Actions
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let managedObjectContext = managedObjectContext else { return }
        
        guard let title = nameTextField.text, !title.isEmpty else {
            showAlert(withTitle: "Name missing", andMessage: "Your list doesn't have any name")
            return
        }
        
        let list = List(context: managedObjectContext)
        
        list.name = title
        
        _ = navigationController?.popViewController(animated: true)
    }

}
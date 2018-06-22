//
//  ListViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet var nameTextField: UITextField!
    
    //MARK: -
    
    var list: List?
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit List"
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
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
    }
    
    private func setupNameTextField() {
        nameTextField.text = list?.name
    }

}

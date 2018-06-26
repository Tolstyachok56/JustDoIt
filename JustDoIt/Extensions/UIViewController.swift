//
//  UIViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(withTitle title: String, andMessage message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

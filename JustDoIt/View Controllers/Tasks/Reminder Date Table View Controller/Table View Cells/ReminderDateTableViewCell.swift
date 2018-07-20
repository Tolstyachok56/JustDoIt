//
//  ReminderDateTableViewCell.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 20.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class ReminderDateTableViewCell: UITableViewCell {
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ReminderDateTableViewCell"
    
    // MARK: - Properties
    
    @IBOutlet weak var delayOptionLabel: UILabel!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

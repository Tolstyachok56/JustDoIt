//
//  TaskTableViewCell.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    //MARK: - Static properties
    
    static let reuseIdentifier = "TaskTableViewCell"
    
    //MARK: - Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkmarkLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    //MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

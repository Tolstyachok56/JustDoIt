//
//  TaskWidgetTableViewCell.swift
//  JustDoIt Widget
//
//  Created by Виктория Бадисова on 12.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class TaskWidgetTableViewCell: UITableViewCell {
    
    //MARK: - Static properies
    
    static let reuseIdentifier = "TaskWidgetTableViewCell"
    
    //MARK: - Properties
    
    @IBOutlet weak var checkmarkLabel: UILabel!
    @IBOutlet weak var listIconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    //MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

//
//  ListTableViewCell.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 21.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    //MARK: - Static properties
    
    static let reuseIdentifier = "ListTableViewCell"
    
    //MARK: - Properties
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberOfItemsLabel: UILabel!
    
    //MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

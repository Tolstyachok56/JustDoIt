//
//  IconTableViewCell.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 09.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class IconTableViewCell: UITableViewCell {
    
    
    //MARK: - Static propeties
    
    static let reuseIdentifier = "IconTableViewCell"
    
    //MARK: - Properties
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconNameLabel: UILabel!
    
    //MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

//
//  IconViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 26.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

protocol IconViewControllerDelegate {
    func controller(_ controller: IconViewController, didPick iconName: String)
}

class IconViewController: UIViewController {
    
    //MARK: - IconNames
    
    private enum IconName: String, CaseIterable {
        
        case NoIcon = "NoIcon"
        
        case Airport = "Airport"
        case Animals = "Animals"
        case Appointments = "Appointments"
        case Baby = "Baby"
        case Birthdays = "Birthdays"
        case Briefcase = "Briefcase"
        case Charts = "Charts"
        case Cloakroom = "Cloakroom"
        case Documents = "Documents"
        case Family = "Family"
        case Folder = "Folder"
        case Groceries = "Groceries"
        case Heart = "Heart"
        case House = "House"
        case Housekeeping = "Housekeeping"
        case Ideas = "Ideas"
        case MapMarker = "MapMarker"
        case Medicine = "Medicine"
        case Messages = "Messages"
        case MoneyBox = "MoneyBox"
        case Payments = "Payments"
        case Tickets = "Tickets"
        case Trash = "Trash"
        
    }
    
    //MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: -
    
    var delegate: IconViewControllerDelegate?
    
    //MARK: -
    
    var iconName: String?
    
    //MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Icons", comment: "IconViewController title")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.controller(self, didPick: iconName ?? "NoIcon")
    }
    
    //MARK: - Helper methods
    
    private func configure(_ cell: IconTableViewCell, at indexPath: IndexPath) {
        
        let listIconNames = IconName.allCases.compactMap { $0.rawValue }
        let listIconName = listIconNames[indexPath.row]
        
        //image
        cell.iconImageView.image = UIImage(named: listIconName)
        
        if listIconName == self.iconName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        //label
        cell.iconNameLabel.text = NSLocalizedString(listIconName, comment: listIconName)
        
    }
    
}

//MARK: - UICollectionViewDataSource methods

extension IconViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let iconNames = IconName.allCases
        return iconNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.reuseIdentifier, for: indexPath) as? IconTableViewCell else {
            fatalError("Unexpected index path")
        }
        configure(cell, at: indexPath)
        return cell
    }
    
}


//MARK: - UICollectionViewDelegate methods

extension IconViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let iconNames = IconName.allCases.compactMap {$0.rawValue}
        self.iconName = iconNames[indexPath.row]
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(0.0001)
    }
    
}

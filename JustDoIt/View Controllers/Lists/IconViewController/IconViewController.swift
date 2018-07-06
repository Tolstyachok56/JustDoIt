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
        case Appointments = "Appointments"
        case Birthdays = "Birthdays"
        case Chores = "Chores"
        case Folder = "Folder"
        case Groceries = "Groceries"
        case Trips = "Trips"
    }
    
    //MARK: - Properties
    
    @IBOutlet var collectionView: UICollectionView!
    
    //MARK: -
    
    var delegate: IconViewControllerDelegate?
    
    //MARK: -
    
    var iconName: String?
    
    //MARK: - Collection view settings
    
    let maxIconWidth: CGFloat = 72
    let minSpacing: CGFloat = 2
    let sectionInset: CGFloat = 2
    
    //MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Icons"

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.controller(self, didPick: iconName ?? "NoIcon")
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: - Helper methods
    
    private func configure(_ cell: IconCollectionViewCell, at indexPath: IndexPath) {
        
        let listIconNames = IconName.allCases.compactMap { $0.rawValue }
        let listIconName = listIconNames[indexPath.row]
        
        cell.imageView.image = UIImage(named: listIconName)
        
        cell.imageView.layer.cornerRadius = 5

        if listIconName == self.iconName {
            cell.imageView.layer.borderWidth = 2
            cell.imageView.layer.borderColor = UIColor.red.cgColor
        } else {
            cell.imageView.layer.borderWidth = 1
            cell.imageView.layer.borderColor = UIColor.black.cgColor
        }
    }
    
}

//MARK: - UICollectionViewDataSource methods

extension IconViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let iconNames = IconName.allCases
        return iconNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconCollectionViewCell.reuseIdentifier, for: indexPath) as? IconCollectionViewCell else {
            fatalError("Unexpected index path")
        }
        configure(cell, at: indexPath)
        return cell
    }

}

//MARK: - UICollectionViewDelegate methods

extension IconViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let iconNames = IconName.allCases.compactMap {$0.rawValue}
        iconName = iconNames[indexPath.row]
        collectionView.reloadData()
    }
    
}

//MARK: - UICollectionViewDelegate methods

extension IconViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let rowWidth = collectionView.bounds.size.width
        let iconsInRow: CGFloat = (rowWidth / maxIconWidth).rounded(.towardZero) + 1
        
        let itemWidth = (rowWidth - 2 * sectionInset - (iconsInRow - 1) * minSpacing) / iconsInRow
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInsets = UIEdgeInsets(top: sectionInset, left: sectionInset, bottom: sectionInset, right: sectionInset)
        return edgeInsets
    }
    
}

//
//  ItemsViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import CoreData

class ItemsViewController: UIViewController {
    
    //MARK: - Segues
    
    private enum Segue{
        static let AddItem = "AddItem"
        static let Item = "Item"
    }
    
    //MARK: - Properties
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    //MARK: -
    
    var list: List?
    
    //MARK: -
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Item> = {

        guard let managedObjectContext = self.list?.managedObjectContext else {
            fatalError("No managed object context found")
        }
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Item.isChecked), ascending: true),
                                        NSSortDescriptor(key: #keyPath(Item.name), ascending: true)]
        
        fetchRequest.predicate = NSPredicate(format: "list == %@", self.list!)

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()
    
    //MARK: -
    
    private var hasItems: Bool {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return false }
        return fetchedObjects.count > 0
    }
    
    //MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = list?.name
 
        setupView()
        fetchItems()
        updateView()
    }
    
    //MARK: - View methods
    
    private func setupView() {
        setupMessageLabel()
        setupBarButtonItems()
        setupTableView()
    }
    
    private func setupMessageLabel() {
        messageLabel.text = "You don't have any items yet"
    }
    
    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(_:)))
    }
    
    private func setupTableView() {
        tableView.estimatedRowHeight = CGFloat(44)
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func updateView() {
        tableView.isHidden = !hasItems
        messageLabel.isHidden = hasItems
    }
    
    //MARK: - Fetching
    
    private func fetchItems() {
        do {
            try fetchedResultsController.performFetch()
        } catch let fetchError {
            print("Unable to perform fetch")
            print("\(fetchError): \(fetchError.localizedDescription)")
        }
    }

    //MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.AddItem:
            guard let destination = segue.destination as? AddItemViewController else { return }
            destination.list = list
        case Segue.Item:
            guard let destination = segue.destination as? ItemViewController else { return }
            guard let cell = sender as? ItemTableViewCell else { return }
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            let item = fetchedResultsController.object(at: indexPath)
            destination.item = item
        default:
            fatalError("Unexpected segue identifier")
        }
    }
    
    //MARK: - Helper methods
    
    private func configure(_ cell:  ItemTableViewCell, at indexPath: IndexPath) {
        let item = fetchedResultsController.object(at: indexPath)
        
        let attributedString = NSMutableAttributedString()
        let strikeAttributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        
        if item.isChecked {
            cell.checkmarkLabel.isHidden = false
            attributedString.append(NSAttributedString(string: item.name!, attributes: strikeAttributes))
        } else {
            cell.checkmarkLabel.isHidden = true
            attributedString.append(NSAttributedString(string: item.name!, attributes: nil))
        }
        
        cell.nameLabel.attributedText = attributedString
        
        cell.checkmarkLabel.textColor = view.tintColor
    }
    
    @objc private func add(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segue.AddItem, sender: sender)
    }

}

//MARK: - UITableViewDataSource methods

extension ItemsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard  let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.reuseIdentifier, for: indexPath) as? ItemTableViewCell else { fatalError("Unexpected index path") }
        
        configure(cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let item = fetchedResultsController.object(at: indexPath)
        item.removeNotification()
        list?.managedObjectContext?.delete(item)
    }
}

// MARK: - UITableViewDelegate methods

extension ItemsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        let item = fetchedResultsController.object(at: indexPath)
        
        item.isChecked = !item.isChecked
        
        item.scheduleNotification()
    }
    
}


//MARK: - NSFetchedResultsControllerDelegate methods

extension ItemsViewController: NSFetchedResultsControllerDelegate  {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? ItemTableViewCell {
                configure(cell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
}

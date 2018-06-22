//
//  ListsViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 21.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import CoreData

class ListsViewController: UIViewController {
    
    // MARK: - Segues
    
    private enum Segue {
        static let AddList = "AddList"
        static let List = "List"
        static let Items = "Items"
    }
    
    // MARK: - Properties
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    // MARK: -
    
    private var coreDataManager = CoreDataManager(modelName: "JustDoIt")
    
    private lazy var fetchedResultsController: NSFetchedResultsController<List> = {
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(List.name), ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.coreDataManager.mainManagedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: -
    
    private var hasLists: Bool {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return false }
        return fetchedObjects.count > 0
    }
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Just Do It"
        
        setupView()
        fetchLists()
        updateView()
    }
    
    // MARK: - View methods
    
    private func setupView() {
        setupMessageLabel()
        setupTableView()
    }
    
    private func setupMessageLabel() {
        messageLabel.text = "You don't have any lists yet"
    }
    
    private func setupTableView() {
        tableView.estimatedRowHeight = CGFloat(44)
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func updateView() {
        tableView.isHidden = !hasLists
        messageLabel.isHidden = hasLists
    }
    
    // MARK: - Fetching
    
    private func fetchLists() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch let fetchError {
            print("Unable to perform fetch")
            print("\(fetchError): \(fetchError.localizedDescription)")
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.AddList:
            guard let destination = segue.destination as? AddListViewController else { return }
            destination.managedObjectContext = coreDataManager.mainManagedObjectContext
        case Segue.List:
            guard let destination = segue.destination as? ListViewController else { return }
            guard let cell = sender as? ListTableViewCell else { return }
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            let list = fetchedResultsController.object(at: indexPath)
            destination.list = list
        case Segue.Items:
            guard let destination = segue.destination as? ItemsViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let list = fetchedResultsController.object(at: indexPath)
            destination.list = list
        default:
            fatalError("Unexpected segue identifier")
        }
    }

    //MARK: - Helper methods
    
    private func configure(_ cell: ListTableViewCell, at indexPath: IndexPath) {
        let list = fetchedResultsController.object(at: indexPath)
        
        cell.nameLabel.text = list.name
        cell.numberOfItemsLabel.text = "\(list.items?.count ?? 0) items"
    }

}

// MARK: - UITableViewDataSource methods

extension ListsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier, for: indexPath) as? ListTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let list = fetchedResultsController.object(at: indexPath)
        
        coreDataManager.mainManagedObjectContext.delete(list)
    }
    
}

//// MARK: - UITableViewDelegate methods
//
//extension ListsViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
//}

// MARK: - NSFetchedResultsControllerDelegate methods

extension ListsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell {
                configure(cell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }
    
}

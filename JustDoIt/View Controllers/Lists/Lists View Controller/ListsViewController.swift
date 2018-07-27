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
        static let Tasks = "Tasks"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: -
    
    private var coreDataManager = CoreDataManager.current
    
    //MARK: -
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        coreDataManager.saveChanges()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - View methods
    
    private func setupView() {
        setupMessageLabel()
        setupTableView()
    }
    
    private func setupMessageLabel() {
        messageLabel.text = NSLocalizedString("You don't have any lists yet", comment: "Text of message label")
    }
    
    private func setupTableView() {
        tableView.estimatedRowHeight = CGFloat(44)
        tableView.rowHeight = UITableViewAutomaticDimension
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
            guard let destination = segue.destination as? AddListTableViewController else { return }
            destination.managedObjectContext = coreDataManager.mainManagedObjectContext
        case Segue.List:
            guard let destination = segue.destination as? ListTableViewController else { return }
            guard let cell = sender as? ListTableViewCell else { return }
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            let list = fetchedResultsController.object(at: indexPath)
            destination.list = list
        case Segue.Tasks:
            guard let destination = segue.destination as? TasksViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let list = fetchedResultsController.object(at: indexPath)
            destination.list = list
            destination.coreDataManager = coreDataManager
        default:
            fatalError("Unexpected segue identifier")
        }
    }

    //MARK: - Helper methods
    
    private func configure(_ cell: ListTableViewCell, at indexPath: IndexPath) {
        let list = fetchedResultsController.object(at: indexPath)
        
        // name label
        cell.nameLabel.text = list.name
        
        // number of tasks label
        if let tasks = list.tasks as? Set<Task>, tasks.count > 0 {
            let uncheckedTasks = Array(tasks).filter { !$0.isChecked }
            
            if uncheckedTasks.count == 0 {
                cell.numberOfTasksLabel.text = NSLocalizedString("All done!", comment: "All tasks in list are done")
            } else {
                cell.numberOfTasksLabel.text = "\(uncheckedTasks.count) " + NSLocalizedString("remaining", comment: "Tasks remaining")
            }
        } else {
            cell.numberOfTasksLabel.text = "[" + NSLocalizedString("No tasks", comment: "There is no tasks in list") + "]"
        }
        
        // icon image view
        if let iconName = list.iconName {
            cell.iconImageView.image = UIImage(named: iconName)
        } else {
            cell.iconImageView.image = UIImage(named: "NoIcon")
        }
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let list = fetchedResultsController.object(at: indexPath)
        
        if let tasks = list.tasks as? Set<Task> {
            for task in tasks {
                task.removeNotification()
            }
        }
        coreDataManager.mainManagedObjectContext.delete(list)
        coreDataManager.saveChanges()
    }
    
}

// MARK: - UITableViewDelegate methods

extension ListsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(0.0001)
    }
    
}

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

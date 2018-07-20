//
//  TasksViewController.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 22.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import CoreData

class TasksViewController: UIViewController {
    
    //MARK: - Segues
    
    private enum Segue{
        static let AddTask = "AddTask"
        static let Task = "Task"
    }
    
    //MARK: - Properties
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: -
    
    var list: List?
    
    //MARK: -
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Task> = {

        guard let managedObjectContext = self.list?.managedObjectContext else {
            fatalError("No managed object context found")
        }
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Task.isChecked), ascending: true),
                                        NSSortDescriptor(key: #keyPath(Task.createdDate), ascending: true)]
        
        fetchRequest.predicate = NSPredicate(format: "list == %@", self.list!)

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()
    
    //MARK: -
    
    private var hasTasks: Bool {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return false }
        return fetchedObjects.count > 0
    }
    
    //MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = list?.name
 
        setupView()
        fetchTasks()
        updateView()
    }
    
    //MARK: - View methods
    
    private func setupView() {
        setupMessageLabel()
        setupBarButtonItems()
        setupTableView()
    }
    
    private func setupMessageLabel() {
        messageLabel.text = NSLocalizedString("You don't have any tasks yet", comment: "Text of message label")
    }
    
    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask(_:)))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func setupTableView() {
        tableView.estimatedRowHeight = CGFloat(44)
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func updateView() {
        tableView.isHidden = !hasTasks
        messageLabel.isHidden = hasTasks
    }
    
    //MARK: - Fetching
    
    private func fetchTasks() {
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
        case Segue.AddTask:
            guard let destination = segue.destination as? AddTaskTableViewController else { return }
            destination.list = list
        case Segue.Task:
            guard let destination = segue.destination as? TaskTableViewController else { return }
            guard let cell = sender as? TaskTableViewCell else { return }
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            let task = fetchedResultsController.object(at: indexPath)
            destination.task = task
        default:
            fatalError("Unexpected segue identifier")
        }
    }
    
    //MARK: - Actions
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        
        guard let listName = list?.name else { return }
        guard let listTasks = fetchedResultsController.fetchedObjects else { return }
        
        var tasks: [String] = []
        for task in listTasks{
            if !task.isChecked {
                tasks.append(task.title!)
            }
        }
        
        let text = "\(listName):\n• \(tasks.joined(separator: "\n• "))"
        
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func clearList(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let removeAllAction = UIAlertAction(title: NSLocalizedString("Remove all", comment: "Remove all"), style: .destructive) { (action) in self.removeAllTasks() }
        let removeCheckedAction = UIAlertAction(title: NSLocalizedString("Remove checked", comment: "Remove checked"), style: .destructive) { (action) in self.removeCheckedTasks() }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        
        alertController.addAction(removeAllAction)
        alertController.addAction(removeCheckedAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Helper methods
    
    private func configure(_ cell:  TaskTableViewCell, at indexPath: IndexPath) {
        let task = fetchedResultsController.object(at: indexPath)
        
        //nameLabel & checkmarkLabel
        let attributedString = NSMutableAttributedString()
        let strikeAttributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        
        if task.isChecked {
            attributedString.append(NSAttributedString(string: task.title!, attributes: strikeAttributes))
            cell.checkmarkLabel.text = "✓"
            cell.nameLabel.textColor = UIColor.lightGray
        } else {
            attributedString.append(NSAttributedString(string: task.title!, attributes: nil))
            cell.checkmarkLabel.text = "❍"
            cell.nameLabel.textColor = UIColor.black
        }
        
        cell.nameLabel.attributedText = attributedString
        cell.checkmarkLabel.textColor = view.tintColor
        
        //dueDateLabel
        cell.dueDateLabel.isHidden = task.isChecked || !task.shouldRemind
        if let dueDate = task.dueDate {
            cell.dueDateLabel.text = Task.dueDateFormatter.string(from: dueDate)
        }
        
    }
    
    @objc private func addTask(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segue.AddTask, sender: sender)
    }
    
    private func removeAllTasks() {
        guard let tasks = fetchedResultsController.fetchedObjects else { return }
        
        for task in tasks {
            removeTask(task)
        }
    }
    
    private func removeCheckedTasks() {
        guard let tasks = fetchedResultsController.fetchedObjects else { return }
        
        let checkedTasks = tasks.filter { $0.isChecked }
        
        for task in checkedTasks {
            removeTask(task)
        }
    }
    
    private func removeTask(_ task: Task) {
        task.removeNotification()
        list?.managedObjectContext?.delete(task)
    }

}

//MARK: - UITableViewDataSource methods

extension TasksViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard  let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier, for: indexPath) as? TaskTableViewCell else { fatalError("Unexpected index path") }
        
        configure(cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let task = fetchedResultsController.object(at: indexPath)
        removeTask(task)
    }
    
}

// MARK: - UITableViewDelegate methods

extension TasksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        let task = fetchedResultsController.object(at: indexPath)
        
        task.isChecked = !task.isChecked
        task.scheduleNotification()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(0.0001)
    }
    
}


//MARK: - NSFetchedResultsControllerDelegate methods

extension TasksViewController: NSFetchedResultsControllerDelegate  {
    
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
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell {
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

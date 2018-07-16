//
//  TodayViewController.swift
//  JustDoIt Widget
//
//  Created by Виктория Бадисова on 12.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageLabel: UILabel!
    
    // MARK: -
    
    private var coreDataManager = CoreDataManager.current
    
    //MARK: -
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Task.dueDate), ascending: true)]
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        
        let startDueDatePredicate = NSPredicate(format: "dueDate >= %@", startDate as CVarArg)
        let endDueDatePredicate = NSPredicate(format: "dueDate < %@", endDate! as CVarArg)
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startDueDatePredicate, endDueDatePredicate])
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.coreDataManager.mainManagedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: -
    
    private var hasTasks: Bool {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return false }
        return fetchedObjects.count > 0
    }
    
    // MARK: - View life cycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchTasks()
        updateView()
    }
    
    // MARK: - View methods
    
    private func setupView() {
        setupWidget()
        setupMessageLabel()
        setupTableView()
    }
    
    private func setupWidget() {
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    private func setupMessageLabel() {
        messageLabel.text = "You don't have any tasks today"
    }
    
    private func setupTableView() {
        tableView.estimatedRowHeight = CGFloat(44)
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func updateView() {
        tableView.isHidden = !hasTasks
        messageLabel.isHidden = hasTasks
    }
    
    // MARK: - Fetching
    
    private func fetchTasks() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch let fetchError {
            print("Unable to perform fetch")
            print("\(fetchError): \(fetchError.localizedDescription)")
        }
    }
    
    // MARK: - Helper methods
    
    private func configure(_ cell: TaskWidgetTableViewCell, at indexPath: IndexPath) {
        let task = fetchedResultsController.object(at: indexPath)
        
        let attributedString = NSMutableAttributedString()
        let strikeAttributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        
        if task.isChecked {
            attributedString.append(NSAttributedString(string: task.title!, attributes: strikeAttributes))
            cell.nameLabel.textColor = UIColor.darkGray
            cell.dueDateLabel.isHidden = true
            cell.checkmarkLabel.text = "✓"
        } else {
            attributedString.append(NSAttributedString(string: task.title!, attributes: nil))
            cell.nameLabel.textColor = UIColor.black
            cell.dueDateLabel.isHidden = false
            cell.checkmarkLabel.text = "❍"
        }
        
        cell.nameLabel.attributedText = attributedString
        
        cell.dueDateLabel.text = Task.dueTimeFormatter.string(from: task.dueDate!)
    }
    
    
}

// MARK: - NCWidgetProviding methods

extension TodayViewController: NCWidgetProviding {
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height: tableView.contentSize.height)
        }
    }
    
}

//MARK: - UITableViewDataSource methods

extension TodayViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskWidgetTableViewCell.reuseIdentifier, for: indexPath) as? TaskWidgetTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
}

//MARK: - UITableViewDelegate methods

extension TodayViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = fetchedResultsController.object(at: indexPath)
        
        task.isChecked = !task.isChecked
        task.scheduleNotification()
        
        coreDataManager.saveChanges()
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate methods

extension TodayViewController: NSFetchedResultsControllerDelegate {
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
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? TaskWidgetTableViewCell {
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

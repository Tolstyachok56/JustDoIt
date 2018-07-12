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
        
        setupView()
        fetchLists()
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
    
    // MARK: - Helper methods
    
    private func configure(_ cell: ListWidgetTableViewCell, at indexPath: IndexPath) {
        let list = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = list.name
        
    }
    
    
}

// MARK: - NCWidgetProviding methods

extension TodayViewController: NCWidgetProviding {
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            
            var contentHeight = CGFloat(110)
            let rowHeight = 44
            if let numberOfLists = fetchedResultsController.fetchedObjects?.count {
                contentHeight = CGFloat(rowHeight * numberOfLists)
            }
            
            self.preferredContentSize = CGSize(width: maxSize.width, height: contentHeight)
        }
    }
    
}

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListWidgetTableViewCell.reuseIdentifier, for: indexPath) as? ListWidgetTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        configure(cell, at: indexPath)
        
        return cell
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
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? ListWidgetTableViewCell {
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

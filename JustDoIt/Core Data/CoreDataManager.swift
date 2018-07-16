//
//  CoreDataManager.swift
//  JustDoIt
//
//  Created by Виктория Бадисова on 21.06.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import CoreData
import UIKit

final class CoreDataManager {
    
    static let current = CoreDataManager(modelName: "JustDoIt")
    
    //MARK: - Properties
    
    private let modelName: String
    
    //MARK: -
    
    private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.privateManagedObjectContext
        return managedObjectContext
    }()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to find data model")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else{
            fatalError("Unable to load data model")
        }
        
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        
//        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        guard let documentsDirectoryURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.vbadisova.JustDoIt.sharingForTodayExtension") else {
             fatalError("Unable to get documents directory")
        }
        
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            let options = [ NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: false]
            
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: options)
        } catch {
            fatalError("Unable to add persistent store")
        }
        
        return persistentStoreCoordinator
    }()
    
    //MARK: - Initialization
    
    private init(modelName: String) {
        self.modelName = modelName
        
        setupNotificationHandling()
    }
    
    //MARK: - Notification handling
    
    @objc func saveChanges(_ notification: Notification) {
        saveChanges()
        print("Core Data Manager: All changes has been saved")
    }
    
    //MARK: - Helper methods
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(saveChanges(_:)),
                                       name: UIApplication.willTerminateNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(saveChanges(_:)),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }

    
    private func saveChanges() {
        mainManagedObjectContext.perform({
            do {
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Main Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
            
            self.privateManagedObjectContext.perform({
                do {
                    if self.privateManagedObjectContext.hasChanges {
                        try self.privateManagedObjectContext.save()
                    }
                } catch {
                    let saveError = error as NSError
                    print("Unable to Save Changes of Private Managed Object Context")
                    print("\(saveError), \(saveError.localizedDescription)")
                }
            })
        })
    }
    
}


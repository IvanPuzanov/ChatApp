//
//  CoreDataService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 09.04.2023.
//

import UIKit
import CoreData

protocol CoreDataServiceProtocol: AnyObject {
    func fetchCachedChannels() throws -> [DBChannel]
    func fetchCachedMessages(for channelID: String) throws -> [DBMessage]
    func save(block: @escaping (NSManagedObjectContext) throws -> Void)
    func delete(block: @escaping (NSManagedObjectContext) throws -> Void)
}

final class CoreDataService {
    // MARK: - Singleton
    
    static let shared = CoreDataService()
    private init() {  }
    
    // MARK: - Core Data Stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Chat")
        container.loadPersistentStores { _, error in
            guard let error else { return }
        }
        return container
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
}

// MARK: - CoreDataServiceProtocol

extension CoreDataService: CoreDataServiceProtocol {
    func fetchCachedChannels() throws -> [DBChannel] {
        let channelsFetchRequest = DBChannel.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "lastActivity", ascending: false)
        channelsFetchRequest.sortDescriptors = [sortDescriptor]
    
        self.log("Channels fetched", #function)
        
        return try viewContext.fetch(channelsFetchRequest)
    }
    
    func fetchCachedMessages(for channelID: String) throws -> [DBMessage] {
        let channelsFetchRequest = DBChannel.fetchRequest()
        channelsFetchRequest.predicate = NSPredicate(format: "channelID == %@", channelID as CVarArg)
        
        guard let messages = try viewContext.fetch(channelsFetchRequest).first?.messages?.allObjects as? [DBMessage] else {
            self.log("Messages didn't fetch", #function)
            return []
        }
        
        return messages
    }
    
    func save(block: @escaping (NSManagedObjectContext) throws -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        backgroundContext.perform {
            do {
                try block(backgroundContext)
                
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                    self.log("Data saved", #function)
                }
            } catch {
                self.log("Data didn't save. Error occured.", #function)
                backgroundContext.rollback()
            }
        }
    }
    
    func delete(block: @escaping (NSManagedObjectContext) throws -> Void) {
        do {
            try block(viewContext)
            log("Data is deleted.", #function)
        } catch {
            log("Data isn't deleted.", #function)
        }
    }
    
    private func log(_ message: String, _ functionName: String) {
        #if !DEBUG
        print(message, functionName)
        #endif
    }
}

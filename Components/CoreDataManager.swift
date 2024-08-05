//
//  CoreDataManager.swift
//  Koronga
//
//  Created by Sam Hawthorne on 2024-08-04.
//

import CoreData
import FamilyControls

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ApplicationProfileModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveApplicationProfile(_ profile: ApplicationProfile) {
        let context = persistentContainer.viewContext
        let entity = ApplicationProfileEntity(context: context)
        entity.id = profile.id
        entity.tokenIdentifier = "\(profile.applicationToken.hashValue)"
        
        saveContext()
    }
    
    func fetchApplicationProfiles() -> [String] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ApplicationProfileEntity> = ApplicationProfileEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.compactMap { $0.tokenIdentifier }
        } catch {
            print("Failed to fetch application profiles: \(error)")
            return []
        }
    }
}

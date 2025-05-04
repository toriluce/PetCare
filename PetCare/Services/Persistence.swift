import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        let container = NSPersistentContainer(name: "PetCare")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.shouldMigrateStoreAutomatically = true
        storeDescription?.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                if error.domain == NSCocoaErrorDomain && error.code == 134110 {
                    if let url = description.url {
                        print("Deleting incompatible store at \(url)")
                        try? FileManager.default.removeItem(at: url)
                        
                        container.loadPersistentStores { _, retryError in
                            if let retryError = retryError {
                                fatalError("Retry store load failed: \(retryError)")
                            }
                        }
                        return
                    }
                }
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.container = container
    }
}

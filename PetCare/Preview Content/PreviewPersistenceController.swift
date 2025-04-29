import Foundation
import CoreData

final class PreviewPersistenceController {
    static let shared = PreviewPersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "PetCare")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null") 
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load preview store: \(error)")
            }
        }
    }
}

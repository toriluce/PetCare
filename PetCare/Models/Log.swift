import Foundation
import CoreData

final class Log: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var taskTitle: String
    @NSManaged var timestamp: Date
    @NSManaged var logPet: Pet
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
    }
}

extension Log {
    static var example: Log {
        let context = PreviewPersistenceController.shared.container.viewContext

        let log = Log(context: context)
        log.id = UUID()
        log.taskTitle = "Tell is Good Boy"
        log.timestamp = Date()

        let pet = Pet(context: context)
        pet.id = UUID()
        pet.name = "Brody"
        pet.breed = "Yorkie"
        pet.species = "Dog"
        pet.birthday = Date()

        log.logPet = pet
        pet.logs = [log]

        return log
    }
}

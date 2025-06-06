import Foundation
import CoreData

final class Log: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var taskTitle: String
    @NSManaged var timestamp: Date
    @NSManaged var pet: Pet
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
    }
}

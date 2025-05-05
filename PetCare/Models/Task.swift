import Foundation
import CoreData

final class Task: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var details: String?
    @NSManaged var isComplete: Bool
    @NSManaged var repeatFrequency: String?
    @NSManaged var timeOfDay: Date?
    @NSManaged var lastCompletedAt: Date?
    @NSManaged var pet: Pet?
    @NSManaged var sortOrder: Int64
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(false, forKey: "isComplete")
    }
}

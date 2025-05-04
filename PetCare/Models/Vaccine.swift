import Foundation
import CoreData

final class Vaccine: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var intervalInDays: Int64
    @NSManaged var lastAdministered: Date?
    @NSManaged var contacts: Set<Contact>?
    @NSManaged var appointments: Set<Appointment>?

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
    }
}

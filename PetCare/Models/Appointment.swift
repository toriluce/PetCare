import Foundation
import CoreData

final class Appointment: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var date: Date
    @NSManaged var pet: Pet
    @NSManaged var contact: Contact?
    @NSManaged var vaccines: Set<Vaccine>?

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
    }
}

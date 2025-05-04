import Foundation
import CoreData

final class Contact: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var phoneNumber: String?
    @NSManaged var address: String?
    @NSManaged var websiteURL: String?
    @NSManaged var vaccines: Set<Vaccine>?
    @NSManaged var appointments: Set<Appointment>?
    @NSManaged var pet: Pet

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
    }
}

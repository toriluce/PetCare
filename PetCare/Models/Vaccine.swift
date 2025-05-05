import Foundation
import CoreData

final class Vaccine: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var intervalInDays: Int64
    @NSManaged var lastAdministered: Date?
    @NSManaged var contacts: Set<Contact>?
    @NSManaged var appointments: Set<Appointment>?
    @NSManaged var pet: Pet

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
    }
}

extension Vaccine {
    var isOverdue: Bool {
        guard let last = lastAdministered else { return true }
        guard let due = Calendar.current.date(byAdding: .day, value: Int(intervalInDays), to: last) else { return true }
        return due < Date()
    }
}

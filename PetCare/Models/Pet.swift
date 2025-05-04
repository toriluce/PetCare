import Foundation
import CoreData

final class Pet: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var breed: String
    @NSManaged var birthday: Date
    @NSManaged var notes: String?
    @NSManaged var species: String
    @NSManaged var tasks: Set<Task>?
    @NSManaged var logs: Set<Log>?
    @NSManaged var contacts: Set<Contact>?
    @NSManaged var appointments: Set<Appointment>?

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
    }

    var nextAppointment: Date? {
        appointments?
            .filter { $0.date >= Date() }
            .sorted { $0.date < $1.date }
            .first?.date
    }

    var sortedContacts: [Contact] {
        contacts?.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending } ?? []
    }

    var sortedAppointments: [Appointment] {
        appointments?.sorted(by: { $0.date < $1.date }) ?? []
    }
    var vaccinesDueSoon: [Vaccine] {
        guard let allVaccines = appointments?.flatMap({ $0.vaccines ?? [] }) else {
            return []
        }

        let now = Date()
        return Array(Set(allVaccines)).filter { vaccine in
            guard let last = vaccine.lastAdministered else { return true }
            guard let dueDate = Calendar.current.date(byAdding: .day, value: Int(vaccine.intervalInDays), to: last) else {
                return true
            }
            return dueDate <= now
        }
    }
}

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
    @NSManaged var vaccines: Set<Vaccine>?
    @NSManaged var photo: Data?

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
    
    var age: String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthday, to: now)

        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0

        switch (years, months, days) {
        case (0, 0, 0..<7):
            return "\(days) day\(days == 1 ? "" : "s") old"
        case (0, 0, _):
            return "\(days) days old"
        case (0, _, _):
            return "\(months) month\(months == 1 ? "" : "s") old"
        case (_, 0, _):
            return "\(years) year\(years == 1 ? "" : "s") old"
        default:
            return "\(years) year\(years == 1 ? "" : "s"), \(months) month\(months == 1 ? "" : "s") old"
        }
    }
    
    var sortedTasks: [Task] {
        (tasks ?? []).sorted {
            if $0.isComplete != $1.isComplete {
                return !$0.isComplete
            }

            guard let time0 = $0.timeOfDay, let time1 = $1.timeOfDay else {
                return $0.timeOfDay != nil
            }

            return time0 < time1
        }
    }
}

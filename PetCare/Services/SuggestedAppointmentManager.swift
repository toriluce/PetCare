import Foundation

struct SuggestedAppointmentManager {
    static func suggestedDate(for vaccines: [Vaccine]) -> Date? {
        vaccines
            .compactMap { vaccine in
                guard let last = vaccine.lastAdministered else { return nil }
                return Calendar.current.date(byAdding: .day, value: Int(vaccine.intervalInDays), to: last)
            }
            .sorted()
            .first
    }

    static func suggestNextAppointmentDate(for pet: Pet) -> Date {
        let dueSoon = pet.vaccinesDueSoon
        return suggestedDate(for: dueSoon) ?? Calendar.current.date(byAdding: .day, value: 30, to: Date())!
    }
}

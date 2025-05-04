import SwiftUI

struct VaccineListView: View {
    var vaccines: [Vaccine]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Vaccines")
                .font(.title2)
                .padding(.bottom, 4)
            
            if vaccines.isEmpty {
                Text("No vaccines recorded.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(vaccines, id: \.id) { vaccine in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vaccine.name)
                            .font(.headline)
                        
                        if let last = vaccine.lastAdministered,
                           let dueDate = Calendar.current.date(byAdding: .day, value: Int(vaccine.intervalInDays), to: last) {
                            
                            Text("Last given: \(last.formatted(date: .abbreviated, time: .omitted))")
                            
                            if isVaccineDue(vaccine: vaccine) {
                                Text("Due now")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            } else {
                                Text("Next due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                            }
                            
                        } else {
                            Text("No record of administration")
                                .foregroundColor(.orange)
                        }
                        
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func isVaccineDue(vaccine: Vaccine) -> Bool {
        guard let last = vaccine.lastAdministered else { return true }
        guard let dueDate = Calendar.current.date(byAdding: .day, value: Int(vaccine.intervalInDays), to: last) else { return true }
        return dueDate <= Date()
    }
}

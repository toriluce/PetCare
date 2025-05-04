import SwiftUI

struct AppointmentsView: View {
    let pets: [Pet]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(pets, id: \.id) { pet in
                Section(header: Text(pet.name)) {
                    
                    if let next = pet.nextAppointment {
                        VStack(alignment: .leading) {
                            Text("Next Appointment:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(next, style: .date)
                        }
                    } else {
                        Text("No upcoming appointments.")
                            .foregroundColor(.secondary)
                    }
                    
                    let appointments = pet.sortedAppointments
                    if !appointments.isEmpty {
                        ForEach(appointments, id: \.id) { appointment in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(appointment.date.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.subheadline)
                                
                                Text("Reason: \(appointment.title)")
                                
                                if let contact = appointment.contact {
                                    Text("\(contact.title)")
                                        .foregroundColor(.secondary)
                                }
                                
                                if let vaccines = appointment.vaccines, !vaccines.isEmpty {
                                    ForEach(Array(vaccines), id: \.id) { vaccine in
                                        Text("💉 \(vaccine.name)")
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    } else {
                        Text("No past appointments.")
                            .foregroundColor(.secondary)
                    }
                    
                    let dueVaccines = pet.vaccinesDueSoon
                    if !dueVaccines.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Vaccines Due Soon:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            ForEach(dueVaccines, id: \.id) { vaccine in
                                Text("• \(vaccine.name)")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    let contacts = pet.sortedContacts
                    if contacts.isEmpty {
                        Text("No contacts available.")
                            .foregroundColor(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contacts:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ForEach(contacts, id: \.id) { contact in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(contact.title)
                                        .fontWeight(.semibold)
                                    if let phone = contact.phoneNumber {
                                        Text("📞 \(phone)")
                                    }
                                    if let address = contact.address {
                                        Text(" \(address)")
                                    }
                                    if let url = contact.websiteURL.flatMap(URL.init) {
                                        Link("Website", destination: url)
                                    }
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
        .navigationTitle("Appointments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

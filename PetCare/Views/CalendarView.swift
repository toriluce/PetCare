import SwiftUI

struct CalendarView: View {
    let pets: [Pet]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var petCareViewModel: PetCareViewModel
    
    @State private var selectedPetForNewAppointment: Pet?
    @State private var appointmentToEdit: (Appointment, Pet)?
    
    var upcomingAppointments: [(Appointment, Pet)] {
        pets.flatMap { pet in
            (pet.appointments ?? []).map { ($0, pet) }
        }
        .filter { $0.0.date >= Date() }
        .sorted { $0.0.date < $1.0.date }
    }
    
    var suggestedAppointments: [(Appointment, Pet)] {
        pets.flatMap { pet in
            petCareViewModel.suggestedAppointments(for: pet, withinDays: 365).map { ($0, pet) }
        }
        .sorted { $0.0.date < $1.0.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if pets.isEmpty {
                EmptyStateView(
                    title: "No Pets or Appointments",
                    message: "Add a pet from the Profile tab to start tracking your upcoming visits.",
                    systemImage: "calendar.badge.exclamationmark"
                )
            } else {
                if upcomingAppointments.isEmpty && suggestedAppointments.isEmpty {
                    EmptyStateView(
                        title: "No Appointments Scheduled",
                        message: "This area will show upcoming and suggested appointments once you've added some.",
                        systemImage: "calendar.badge.clock"
                    )
                } else {
                    GroupBox(label: Label("Upcoming Appointments", systemImage: "calendar")) {
                        if upcomingAppointments.isEmpty {
                            Spacer()
                            Text("No upcoming appointments.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(upcomingAppointments, id: \.0.id) { (appointment, pet) in
                                appointmentRow(for: appointment, pet: pet)
                            }
                        }
                    }
                    
                    GroupBox(label: Label("Suggested Appointments", systemImage: "calendar.badge.clock")) {
                        if suggestedAppointments.isEmpty {
                            Text("No suggested appointments.")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(suggestedAppointments, id: \.0.id) { (appointment, pet) in
                                appointmentRow(for: appointment, pet: pet, isSuggested: true)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    if let firstPet = pets.first {
                        selectedPetForNewAppointment = firstPet
                    }
                } label: {
                    Label("Add Appointment", systemImage: "plus")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .navigationTitle("Appointments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Label("Close", systemImage: "xmark")
                }
            }
        }
        .sheet(item: $selectedPetForNewAppointment) { pet in
            AppointmentFormView(pet: pet)
                .environment(\.managedObjectContext, context)
                .environmentObject(petCareViewModel)
        }
        .sheet(item: Binding(get: {
            appointmentToEdit?.0
        }, set: { _ in
            appointmentToEdit = nil
        })) { appointment in
            if let pet = appointmentToEdit?.1 {
                AppointmentFormView(pet: pet, existingAppointment: appointment)
                    .environment(\.managedObjectContext, context)
                    .environmentObject(petCareViewModel)
            }
        }
    }
    
    @ViewBuilder
    private func appointmentRow(for appointment: Appointment, pet: Pet, isSuggested: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(appointment.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                Spacer()
                if let data = pet.photo, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.accentColor, lineWidth: 1))
                } else {
                    Text(pet.name)
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                        .lineLimit(1)
                }
            }
            
            Text("Reason: \(appointment.title)")
            
            if let contact = appointment.contact {
                Text(contact.title)
                    .foregroundColor(.secondary)
            }
            
            if let vaccines = appointment.vaccines, !vaccines.isEmpty {
                ForEach(Array(vaccines), id: \.id) { vaccine in
                    Text("Vaccine Scheduled: \(vaccine.name)")
                        .foregroundColor(vaccine.isOverdue ? .red : .primary)
                }
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isSuggested {
                appointmentToEdit = (appointment, pet)
            }
        }
        .opacity(isSuggested ? 0.6 : 1.0)
    }
}

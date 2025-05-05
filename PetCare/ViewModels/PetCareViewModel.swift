import Foundation
import SwiftUI
import CoreData

class PetCareViewModel: ObservableObject {
    @Published var pets: [Pet] = []

    // Fetch
    func fetchPets(context: NSManagedObjectContext) {
        let request = NSFetchRequest<Pet>(entityName: "Pet")
        do {
            pets = try context.fetch(request)
        } catch {
            print("Failed to fetch pets: \(error)")
        }
    }

    // Pet Functions
    func addPet(name: String, breed: String, species: String, birthday: Date?, notes: String?, context: NSManagedObjectContext) {
        let newPet = Pet(context: context)
        newPet.name = name
        newPet.breed = breed
        newPet.species = species
        newPet.birthday = birthday ?? Date()
        newPet.notes = notes

        saveContext(context)
    }

    func editPet(_ pet: Pet, name: String, breed: String, species: String, birthday: Date, notes: String, context: NSManagedObjectContext) {
        pet.name = name
        pet.breed = breed
        pet.species = species
        pet.birthday = birthday
        pet.notes = notes

        saveContext(context)
    }

    func deletePet(_ pet: Pet, context: NSManagedObjectContext) {
        context.delete(pet)
        saveContext(context)
    }

    // Task Functions
    func addOrEditTask(for pet: Pet, existingTask: Task? = nil, title: String, details: String, isComplete: Bool, repeatFrequency: String?, timeOfDay: Date?, context: NSManagedObjectContext) -> Task {
        let task = existingTask ?? Task(context: context)

        task.title = title
        task.details = details
        task.isComplete = isComplete
        task.repeatFrequency = repeatFrequency
        task.timeOfDay = timeOfDay
        task.pet = pet

        if existingTask == nil {
            task.sortOrder = Int64(pet.tasks?.count ?? 0)
            pet.tasks?.insert(task)
        }

        saveContext(context)

        TaskNotificationManager.shared.cancelNotification(for: task)
        if !task.isComplete {
            TaskNotificationManager.shared.scheduleNotification(for: task)
        }

        return task
    }

    func completeTask(_ task: Task, context: NSManagedObjectContext) {
        task.isComplete = true
        task.lastCompletedAt = Date()

        let log = Log(context: context)
        log.timestamp = Date()
        log.taskTitle = task.title
        log.pet = task.pet

        saveContext(context)

        TaskNotificationManager.shared.cancelNotification(for: task)
    }

    func deleteTask(_ task: Task, from pet: Pet, context: NSManagedObjectContext) {
        pet.tasks?.remove(task)
        context.delete(task)
        saveContext(context)
    }

    func resetTasksIfNeeded(for pet: Pet, context: NSManagedObjectContext) {
        let now = Date()
        let resetTime = Calendar.current.date(bySettingHour: 2, minute: 0, second: 0, of: now) ?? now

        pet.tasks?.forEach { task in
            if let lastDone = task.lastCompletedAt, lastDone < resetTime {
                task.isComplete = false
                TaskNotificationManager.shared.scheduleNotification(for: task)
            }
        }

        try? context.save()
    }

    // Contact Funtcions
    func addOrEditContact(for pet: Pet, existingContact: Contact? = nil, title: String, phoneNumber: String?, address: String?, websiteURL: String?, context: NSManagedObjectContext) {
        let contact = existingContact ?? Contact(context: context)

        contact.title = title
        contact.phoneNumber = phoneNumber
        contact.address = address
        contact.websiteURL = websiteURL
        contact.pet = pet

        pet.contacts?.insert(contact)

        saveContext(context)
    }

    func deleteContact(_ contact: Contact, context: NSManagedObjectContext) {
        context.delete(contact)
        saveContext(context)
    }

    // Appointment Functions
    func addOrEditAppointment(
        for pet: Pet,
        existingAppointment: Appointment? = nil,
        title: String,
        date: Date,
        contact: Contact,
        vaccines: [Vaccine] = [],
        notes: String?,
        intervalInDays: Int64 = 0,
        lastAppointment: Date? = nil,
        context: NSManagedObjectContext
    ) {
        let appointment = existingAppointment ?? Appointment(context: context)

        appointment.title = title
        appointment.date = date
        appointment.contact = contact
        appointment.pet = pet
        appointment.vaccines = Set(vaccines)
        appointment.notes = notes
        appointment.intervalInDays = intervalInDays
        appointment.lastAppointment = lastAppointment

        pet.appointments?.insert(appointment)

        saveContext(context)
    }

    func deleteAppointment(_ appointment: Appointment, from pet: Pet, context: NSManagedObjectContext) {
        pet.appointments?.remove(appointment)
        context.delete(appointment)
        saveContext(context)
    }

    func suggestedAppointments(for pet: Pet, withinDays limit: Int = 30) -> [Appointment] {
        let now = Date()
        let calendar = Calendar.current

        return pet.appointments?.compactMap { appointment in
            let interval = Int(appointment.intervalInDays)
            guard interval > 0,
                  let last = appointment.lastAppointment,
                  let nextDue = calendar.date(byAdding: .day, value: interval, to: last),
                  nextDue <= calendar.date(byAdding: .day, value: limit, to: now)! else {
                return nil
            }

            let context = appointment.managedObjectContext!
            let upcoming = Appointment(context: context)
            upcoming.title = appointment.title + " (Suggested)"
            upcoming.date = nextDue
            upcoming.pet = pet
            upcoming.contact = appointment.contact
            upcoming.notes = appointment.notes
            upcoming.vaccines = appointment.vaccines
            upcoming.intervalInDays = appointment.intervalInDays
            upcoming.lastAppointment = last

            return upcoming
        } ?? []
    }

    // Vaccine Functions
    func addOrEditVaccine(name: String, intervalInDays: Int64, lastAdministered: Date, contact: Contact, pet: Pet, existingVaccine: Vaccine? = nil, context: NSManagedObjectContext) {
        let vaccine = existingVaccine ?? Vaccine(context: context)

        vaccine.name = name
        vaccine.intervalInDays = intervalInDays
        vaccine.lastAdministered = lastAdministered
        vaccine.contacts = [contact]
        vaccine.pet = pet

        pet.vaccines?.insert(vaccine)

        saveContext(context)
    }

    func deleteVaccine(_ vaccine: Vaccine, context: NSManagedObjectContext) {
        context.delete(vaccine)
        saveContext(context)
    }

    // Save
    private func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

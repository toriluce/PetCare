import Foundation
import SwiftUI
import CoreData

class PetCareViewModel: ObservableObject {
    @Published var pets: [Pet] = []

    func fetchPets(context: NSManagedObjectContext) {
        let request = NSFetchRequest<Pet>(entityName: "Pet")
        do {
            pets = try context.fetch(request)
        } catch {
            print("Failed to fetch pets: \(error)")
        }
    }

    func addPet(name: String, breed: String, species: String, birthday: Date?, notes: String?, context: NSManagedObjectContext) {
        let newPet = Pet(context: context)
        newPet.name = name
        newPet.breed = breed
        newPet.species = species
        newPet.birthday = birthday ?? Date()
        newPet.notes = notes ?? ""

        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to save pet: \(error)")
        }
    }

    func addOrEditTask(
        for pet: Pet,
        existingTask: Task? = nil,
        title: String,
        details: String,
        isComplete: Bool,
        frequency: String?,
        timeOfDay: Date?,
        context: NSManagedObjectContext
    ) -> Task {
        let task = existingTask ?? Task(context: context)

        task.title = title
        task.details = details
        task.isComplete = isComplete
        task.frequency = frequency
        task.timeOfDay = timeOfDay
        task.pet = pet

        if existingTask == nil {
            task.sortOrder = Int64(pet.tasks?.count ?? 0)
            var taskSet = pet.tasks ?? []
            taskSet.insert(task)
            pet.tasks = taskSet
        }

        do {
            try context.save()
            fetchPets(context: context)

            TaskNotificationManager.shared.cancelNotification(for: task)
            if !task.isComplete {
                TaskNotificationManager.shared.scheduleNotification(for: task)
            }
        } catch {
            print("Failed to save or update task: \(error)")
        }

        return task
    }

    func editPet(_ pet: Pet, name: String, breed: String, species: String, birthday: Date, notes: String, context: NSManagedObjectContext) {
        pet.name = name
        pet.breed = breed
        pet.species = species
        pet.birthday = birthday
        pet.notes = notes

        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to edit pet: \(error)")
        }
    }

    func deletePet(_ pet: Pet, context: NSManagedObjectContext) {
        context.delete(pet)
        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to delete pet: \(error)")
        }
    }

    func deleteTask(_ task: Task, from pet: Pet, context: NSManagedObjectContext) {
        var taskSet = pet.tasks ?? []
        taskSet.remove(task)
        pet.tasks = taskSet
        context.delete(task)

        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to delete task: \(error)")
        }
    }

    func resetTasksIfNeeded(for pet: Pet, context: NSManagedObjectContext) {
        let now = Date()
        let calendar = Calendar.current
        let resetTime = calendar.date(bySettingHour: 2, minute: 0, second: 0, of: now)!

        pet.tasks?.forEach { task in
            if let lastDone = task.lastCompletedAt, lastDone < resetTime {
                task.isComplete = false
                TaskNotificationManager.shared.scheduleNotification(for: task)
            }
        }

        try? context.save()
    }

    func completeTask(_ task: Task, context: NSManagedObjectContext) {
        guard let pet = task.pet else {
            print("Log Failed: Task has no associated pet.")
            return
        }

        task.isComplete = true
        task.lastCompletedAt = Date()

        let log = Log(context: context)
        log.timestamp = Date()
        log.taskTitle = task.title
        log.pet = pet

        do {
            try context.save()
            TaskNotificationManager.shared.cancelNotification(for: task)
        } catch {
            print("Failed to complete task: \(error)")
        }
    }

    func addOrEditContact(
        for pet: Pet,
        existingContact: Contact? = nil,
        title: String,
        phoneNumber: String?,
        address: String?,
        websiteURL: String?,
        context: NSManagedObjectContext
    ) {
        let contact = existingContact ?? Contact(context: context)

        contact.title = title
        contact.phoneNumber = phoneNumber
        contact.address = address
        contact.websiteURL = websiteURL
        contact.pet = pet

        if existingContact == nil {
            var currentContacts = pet.contacts ?? []
            currentContacts.insert(contact)
            pet.contacts = currentContacts
        }

        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to save or update contact: \(error)")
        }
    }

    func deleteContact(_ contact: Contact, context: NSManagedObjectContext) {
        context.delete(contact)
        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to delete contact: \(error)")
        }
    }

    func addOrEditAppointment(
        for pet: Pet,
        existingAppointment: Appointment? = nil,
        title: String,
        date: Date,
        contact: Contact,
        vaccines: [Vaccine] = [],
        context: NSManagedObjectContext
    ) {
        let appointment = existingAppointment ?? Appointment(context: context)
        appointment.title = title
        appointment.date = date
        appointment.pet = pet
        appointment.contact = contact
        appointment.vaccines = Set(vaccines)

        if existingAppointment == nil {
            var appts = pet.appointments ?? []
            appts.insert(appointment)
            pet.appointments = appts
        }

        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to save or update appointment: \(error)")
        }
    }

    func deleteAppointment(_ appointment: Appointment, from pet: Pet, context: NSManagedObjectContext) {
        pet.appointments?.remove(appointment)
        context.delete(appointment)

        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to delete appointment: \(error)")
        }
    }

    func addOrEditVaccine(
        name: String,
        intervalInDays: Int64,
        lastAdministered: Date,
        contact: Contact,
        existingVaccine: Vaccine? = nil,
        context: NSManagedObjectContext
    ) {
        let vaccine = existingVaccine ?? Vaccine(context: context)
        vaccine.name = name
        vaccine.intervalInDays = intervalInDays
        vaccine.lastAdministered = lastAdministered
        vaccine.contacts = [contact]

        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to save or update vaccine: \(error)")
        }
    }

    func deleteVaccine(_ vaccine: Vaccine, context: NSManagedObjectContext) {
        context.delete(vaccine)
        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to delete vaccine: \(error)")
        }
    }
}

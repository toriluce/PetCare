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
    
    func addPet(name: String, breed: String, species: String, birthday: Date?, context: NSManagedObjectContext) {
        let newPet = Pet(context: context)
        newPet.name = name
        newPet.breed = breed
        newPet.species = species
        newPet.birthday = birthday ?? Date()
        
        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to save pet: \(error)")
        }
    }
    
    func addTask(to pet: Pet, title: String, details: String, isComplete: Bool, frequency: String?, timeOfDay: Date?, context: NSManagedObjectContext) {
        let newTask = Task(context: context)
        newTask.title = title
        newTask.details = details
        newTask.isComplete = isComplete
        newTask.frequency = frequency
        newTask.timeOfDay = timeOfDay
        newTask.taskPet = pet
        
        var taskSet = pet.tasks ?? []
        taskSet.insert(newTask)
        pet.tasks = taskSet
        
        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to save task: \(error)")
        }
    }
    
    func editPet(_ pet: Pet, name: String, breed: String, species: String, birthday: Date, context: NSManagedObjectContext) {
        pet.name = name
        pet.breed = breed
        pet.species = species
        pet.birthday = birthday
        
        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to edit pet: \(error)")
        }
    }
    
    func editTask(_ task: Task, title: String, details: String, isComplete: Bool, frequency: String?, timeOfDay: Date?, context: NSManagedObjectContext) {
        task.title = title
        task.details = details
        task.isComplete = isComplete
        task.frequency = frequency
        task.timeOfDay = timeOfDay
        
        do {
            try context.save()
            fetchPets(context: context)
        } catch {
            print("Failed to edit task: \(error)")
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
            }
        }
        
        try? context.save()
    }
    
    func completeTask(_ task: Task, context: NSManagedObjectContext) {
        guard let pet = task.taskPet else {
            print("Log Failed: Task has no associated pet.")
            return
        }
        
        task.isComplete = true
        task.lastCompletedAt = Date()
        
        let log = Log(context: context)
        log.timestamp = Date()
        log.taskTitle = task.title
        log.logPet = pet
        
        try? context.save()
    }
}

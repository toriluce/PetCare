import Foundation
import UserNotifications
import CoreData

final class TaskNotificationManager {
    static let shared = TaskNotificationManager()
    
    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            print("Notification permission granted: \(granted)")
        }
    }

    func scheduleNotification(for task: Task) {
        guard let time = task.timeOfDay, !task.isComplete else { return }
        
        let notificationTime = Calendar.current.date(byAdding: .minute, value: 30, to: time)!
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "“\(task.title)” still hasn't been completed."
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    func scheduleAppointmentReminder(for appointment: Appointment) {
        let reminderDate = Calendar.current.date(byAdding: .day, value: -7, to: appointment.date)
        guard let triggerDate = reminderDate, triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Appointment"
        content.body = "“\(appointment.title)” for \(appointment.pet.name) is in 1 week."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: appointment.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule appointment reminder: \(error)")
            }
        }
    }

    func scheduleVaccineReminder(for vaccine: Vaccine) {
        guard let lastDate = vaccine.lastAdministered else { return }
        let dueDate = Calendar.current.date(byAdding: .day, value: Int(vaccine.intervalInDays), to: lastDate)!
        let remindDate = Calendar.current.date(byAdding: .day, value: -60, to: dueDate)!

        guard remindDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Vaccine Reminder"
        content.body = "\(vaccine.name) is due soon for \(vaccine.pet.name)."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: remindDate),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: vaccine.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule vaccine reminder: \(error)")
            }
        }
    }

    func cancelNotification(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test reminder."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Test notification error: \(error)")
            } else {
                print("Test notification scheduled.")
            }
        }
    }

    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending Notifications: \(requests.count)")
            for request in requests {
                print("• ID: \(request.identifier)")
                print("  Title: \(request.content.title)")
                print("  Body: \(request.content.body)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let date = trigger.nextTriggerDate()
                    print("  Scheduled for: \(date?.formatted() ?? "Unknown")")
                }
            }
        }
    }
}

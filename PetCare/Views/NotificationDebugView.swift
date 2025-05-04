import SwiftUI

struct NotificationDebugView: View {
    var body: some View {
        Section(header: Text("Development-Only Notification Debug")) {
            Button("Request Permission") {
                TaskNotificationManager.shared.requestPermission()
            }
            
            Button("Send Test Notification") {
                TaskNotificationManager.shared.scheduleTestNotification()
            }
            
            Button("List All Scheduled Notifications") {
                TaskNotificationManager.shared.listScheduledNotifications()
            }
            
            Button("Cancel All Notifications") {
                TaskNotificationManager.shared.cancelAll()
            }
            .foregroundColor(.red)
        }
    }
}

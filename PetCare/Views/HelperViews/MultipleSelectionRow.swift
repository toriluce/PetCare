import SwiftUI

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    var isOverdue: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(isOverdue ? .red : (isSelected ? .primary : .gray))
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .purple : .gray)
            }
        }
        .buttonStyle(.plain)
    }
}

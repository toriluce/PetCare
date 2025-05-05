import SwiftUI
import CoreData

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showingAddPet = false
    @State private var petToDelete: Pet?
    @State private var showDeleteAlert = false

    @FetchRequest(
        entity: Pet.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)]
    ) var pets: FetchedResults<Pet>

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if pets.isEmpty {
                EmptyStateView(
                    title: "No Pets Yet",
                    message: "Tap the button below to add your first pet.",
                    systemImage: "pawprint"
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        Text("Your Pets")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(pets, id: \.id) { pet in
                            NavigationLink(destination: PetDetailView(pet: pet)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(pet.name)
                                        .font(.headline)
                                    Text(pet.age)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }

#if DEBUG
                        Spacer()
                        NotificationDebugView()
                            .padding(.horizontal)
#endif
                    }
                    .padding(.vertical)
                }
            }

            Button(action: {
                showingAddPet = true
            }) {
                Label("Add Pet", systemImage: "plus")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding([.horizontal, .bottom])
        }
        .background(Color(.systemBackground))
        .navigationTitle("Profile")
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
        .sheet(isPresented: $showingAddPet) {
            PetFormView()
                .environment(\.managedObjectContext, context)
        }
    }
}

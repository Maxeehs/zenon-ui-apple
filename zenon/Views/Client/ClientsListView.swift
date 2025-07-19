import SwiftUI

struct ClientsListView: View {
    @StateObject private var vm = ClientsViewModel()
    @State private var showAddSheet = false
    @State private var newClientName = ""

    var body: some View {
        NavigationView {
            List {
                if vm.isLoading {
                    ProgressView("Chargement…")
                } else {
                    ForEach(vm.clients) { client in
                        Text(client.nom)
                    }
                    .onDelete { offsets in
                        Task {
                            await vm.deleteClients(at: offsets)
                        }
                    }
                }
            }
            .navigationTitle("Mes clients")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddSheet = true }) {
                        Label("Ajouter", systemImage: "plus")
                    }
                }
            }
            .task { await vm.loadClients() }
            .sheet(isPresented: $showAddSheet) {
                VStack(spacing: 16) {
                    Text("Nouveau client")
                        .font(.headline)
                    TextField("Nom du client", text: $newClientName)
                        .textFieldStyle(.roundedBorder)
                    HStack {
                        Button("Annuler") { showAddSheet = false }
                        Spacer()
                        Button("Ajouter") {
                            Task {
                                await vm.addClient(name: newClientName)
                                newClientName = ""
                                showAddSheet = false
                            }
                        }
                        .disabled(newClientName.isEmpty)
                    }
                }
                .padding()
                .frame(width: 300)
            }
        }
    }
}

struct ClientsListView_Previews: PreviewProvider {
    static var previews: some View {
        ClientsListView()
    }
}

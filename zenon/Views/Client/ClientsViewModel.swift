import Foundation
import SwiftUI

@MainActor
class ClientsViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadClients() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await APIClient.shared.fetchClients()
            clients = fetched
        } catch {
            errorMessage = "Erreur au chargement des clients: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func addClient(name: String) async {
        isLoading = true
        do {
            let newClient = try await APIClient.shared.addClient(name: name)
            clients.append(newClient)
        } catch {
            errorMessage = "Impossible d'ajouter le client: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func deleteClients(at offsets: IndexSet) async {
        for index in offsets {
            let client = clients[index]
            do {
                try await APIClient.shared.deleteClient(id: client.id)
                clients.remove(at: index)
            } catch {
                errorMessage = "Impossible de supprimer le client: \(error.localizedDescription)"
            }
        }
    }
}

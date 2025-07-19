import Foundation

extension APIClient {
    /// Récupère la liste des clients de l'utilisateur
        func fetchClients() async throws -> [Client] {
            guard let url = URL(string: "/api/clients", relativeTo: baseURL) else {
                throw APIError.invalidURL
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            // Ajout du JWT si nécessaire
            if let token = jwtToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                throw APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            return try JSONDecoder().decode([Client].self, from: data)
        }

        /// Ajoute un nouveau client
        func addClient(name: String) async throws -> Client {
            guard let url = URL(string: "/api/clients", relativeTo: baseURL) else {
                throw APIError.invalidURL
            }
            let body = ["name": name]
            let dataBody = try JSONEncoder().encode(body)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = jwtToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = dataBody
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                throw APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            return try JSONDecoder().decode(Client.self, from: data)
        }

        /// Supprime un client par son ID
        func deleteClient(id: Int) async throws {
            guard let url = URL(string: "/api/clients/\(id)", relativeTo: baseURL) else {
                throw APIError.invalidURL
            }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            if let token = jwtToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                throw APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
        }
}

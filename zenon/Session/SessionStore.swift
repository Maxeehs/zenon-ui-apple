import Foundation
import SwiftUI

@MainActor
final class SessionStore: ObservableObject {
    // MARK: - États publiés par le ViewModel
    @Published var isAuthenticated: Bool = false
    @Published var token: String? = nil
    @Published var userEmail: String? = nil   // Exemple, à vous d'ajouter ce que vous voulez
    
    private let service = "org.alnitaka.zenon"
    private let account = "authToken"

    /// À l'initialisation, on tente de récupérer un token dans le Keychain.
    init() {
        loadTokenFromKeychain()
    }
  
    /// Lit le token du Keychain. Si trouvé, on le stocke dans `self.token` et on passe `isAuthenticated = true`.
    private func loadTokenFromKeychain() {
        if let data = KeychainHelper.read(service: service, account: account),
           let savedToken = String(data: data, encoding: .utf8) {
                self.token = savedToken
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
            }
    }
  
    /// Appel à l'API pour se connecter.
    /// En cas de succès, on stocke le token dans Keychain et on met à jour l'état.
    func login(email: String, password: String) async -> String? {
        do {
            let response = try await APIClient.shared.login(email: email, password: password)
            let jwt = response.token
            // 1. Sauvegarder dans Keychain
            if let data = jwt.data(using: .utf8) {
                let status = KeychainHelper.save(data, service: service, account: account)
                if status != errSecSuccess {
                    print("Erreur Keychain.save: \(status)")
                }
            }
            // 2. Mettre à jour la session
            self.token = jwt
            self.isAuthenticated = true
            self.userEmail = email
            return nil   // Pas d'erreur, on retourne nil
        } catch let apiError as APIError {
            switch apiError {
                case .serverError(let code):
                    return "Erreur serveur : code \(code)"
                case .decodingError:
                    return "Impossible de décoder la réponse du serveur."
                case .invalidResponse:
                    return "Réponse invalide du serveur."
                case .invalidURL:
                    return "URL invalide."
                case .unknown(let err):
                    return "Erreur inconnue : \(err.localizedDescription)"
            }
        } catch {
            return "Erreur inconnue : \(error.localizedDescription)"
        }
    }
  
    /// Appel à l'API pour s'inscrire.
    /// En cas de succès, on peut soit forcer un login, soit récupérer un message.
    func register(email: String, password: String, firstname: String, lastname: String) async -> String? {
        do {
            let response = try await APIClient.shared.register(email: email, password: password, firstname: firstname, lastname: lastname)
            let jwt = response.token

            if let data = jwt.data(using: .utf8) {
                let status = KeychainHelper.save(data, service: service, account: account)
                if status != errSecSuccess {
                    print("Erreur Keychain.save: \(status)")
                }
            }
            
            self.token = jwt
            self.isAuthenticated = true
            self.userEmail = email
            
            return nil
            } catch let apiError as APIError {
                switch apiError {
                    case .serverError(let code):
                        return "Erreur serveur : code \(code)"
                    case .decodingError:
                        return "Impossible de décoder la réponse du serveur."
                    case .invalidResponse:
                        return "Réponse invalide du serveur."
                    case .invalidURL:
                        return "URL invalide."
                    case .unknown(let err):
                        return "Erreur inconnue : \(err.localizedDescription)"
                }
            } catch {
                return "Erreur inconnue : \(error.localizedDescription)"
        }
    }
  
    /// Déconnexion : on supprime le token du Keychain et on remet l'état à false.
    func signOut() {
        // 1. Supprime le token du Keychain
        KeychainHelper.delete(service: service, account: account)
        
        // 2. Réinitialise l’état local
        self.token = nil
        self.isAuthenticated = false
        self.userEmail = nil
        
        // 3. Efface le jwtToken stocké dans l’actor APIClient
        Task {
            await APIClient.shared.clearToken()
        }
    }
}

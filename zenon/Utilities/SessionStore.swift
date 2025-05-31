import Foundation
import SwiftUI

@MainActor
final class SessionStore: ObservableObject {
  // MARK: - États publiés par le ViewModel
  @Published var isAuthenticated: Bool = false
  @Published var token: String? = nil
  @Published var userEmail: String? = nil   // Exemple, à vous d'ajouter ce que vous voulez
  
  /// À l'initialisation, on tente de récupérer un token dans le Keychain.
  init() {
    loadTokenFromKeychain()
  }
  
  /// Lit le token du Keychain. Si trouvé, on le stocke dans `self.token` et on passe `isAuthenticated = true`.
  private func loadTokenFromKeychain() {
    let service = "org.alnitaka.zenon"
    let account = "authToken"
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
        let status = KeychainHelper.save(data,
                                         service: "org.alnitaka.zenon",
                                         account: "authToken")
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
      // Si votre API renvoie directement un token ici, faites comme pour login
      // Par exemple, si RegisterResponse contient un 'token', vous feriez la même chose que plus haut.
      
      // Si l'API ne renvoie qu'un message, vous pouvez renvoyer ce message pour l'afficher dans l'UI.
      // Puis l'utilisateur devra appeler login séparément.
        return response.token
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
    let service = "org.alnitaka.zenon"
    let account = "authToken"
    KeychainHelper.delete(service: service, account: account)
    self.token = nil
    self.isAuthenticated = false
    self.userEmail = nil
  }
}

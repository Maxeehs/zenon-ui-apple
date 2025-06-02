import Foundation

/// Les erreurs possibles lors d'un appel réseau vers notre API.
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case serverError(statusCode: Int)
    case unknown(Error)
}

/// Structure pour la réponse du endpoint /login
struct LoginResponse: Decodable {
    let token: String
    let type: String
}

/// Structure pour la requête /login
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

/// Structure pour la réponse du endpoint /register
struct RegisterResponse: Decodable {
    let token: String
    let type: String
}

/// Structure pour la requête /register
struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let firstname: String
    let lastname: String
}

/// Actor unique responsable de tous les appels réseau vers votre API.
actor APIClient {
    static let shared = APIClient()
  
    /// L'adresse de base de votre API.
    private let baseURL = URL(string: "http://localhost:8080")!
    var jwtToken: String? = nil
  
    private init() {} // Empêche l'instanciation en dehors
  
    // ----------------------------------------------------------------------
    // MARK: - Login
    // ----------------------------------------------------------------------

    /// Envoie une requête POST /login avec email/mot de passe,
    /// décode la réponse en LoginResponse.
    func login(email: String, password: String) async throws -> LoginResponse {
        // 1. Construire l'URL : baseURL + "/login"
        guard let url = URL(string: "/api/auth/login", relativeTo: baseURL) else {
          throw APIError.invalidURL
        }
        
        // 2. Préparer le corps de la requête (JSON)
        let loginReq = LoginRequest(email: email, password: password)
        let encoder = JSONEncoder()
        let jsonData: Data
        do {
          jsonData = try encoder.encode(loginReq)
        } catch {
          throw APIError.unknown(error)
        }
        
        // 3. Construire l'URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // 4. Envoyer la requête et recevoir (data, response)
        let (data, response): (Data, URLResponse)
        do {
          (data, response) = try await URLSession.shared.data(for: request)
        } catch {
          throw APIError.unknown(error)
        }
        
        // 5. Vérifier le code HTTP
        guard let httpResponse = response as? HTTPURLResponse else {
          throw APIError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
          throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // 6. Décoder le JSON en LoginResponse
        do {
          let decoder = JSONDecoder()
          let loginResponse = try decoder.decode(LoginResponse.self, from: data)
          return loginResponse
        } catch {
          throw APIError.decodingError(error)
        }
    }
  
    // ----------------------------------------------------------------------
    // MARK: - Register
    // ----------------------------------------------------------------------

    /// Envoie une requête POST /register avec email/mot de passe,
    /// décode la réponse en RegisterResponse.
    func register(email: String, password: String, firstname: String, lastname: String) async throws -> RegisterResponse {
        guard let url = URL(string: "/api/auth/register", relativeTo: baseURL) else {
          throw APIError.invalidURL
        }
        
        let registerReq = RegisterRequest(email: email, password: password, firstname: firstname, lastname: lastname)
        let encoder = JSONEncoder()
        let jsonData: Data
        do {
          jsonData = try encoder.encode(registerReq)
        } catch {
          throw APIError.unknown(error)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response): (Data, URLResponse)
        do {
          (data, response) = try await URLSession.shared.data(for: request)
        } catch {
          throw APIError.unknown(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
          throw APIError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
          throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // 6. Décode le JSON en RegisterResponse
        let decoder = JSONDecoder()
        let registerResponse = try decoder.decode(RegisterResponse.self, from: data)

        // 7. Stocke le token retourné pour les futurs appels protégés
        self.jwtToken = registerResponse.token

        return registerResponse
    }
  
    // ----------------------------------------------------------------------
    // MARK: - Exemple d'appel authé (avec JWT)
    // ----------------------------------------------------------------------

    /// Exemple générique de requête GET à un endpoint protégé ("/me"),
    /// en envoyant le token JWT dans le header Authorization.
    func fetchProfile(token: String) async throws -> User {
        // Imaginons que votre API ait un endpoint GET /me qui renvoie un profil
        guard let url = URL(string: "/api/users/me", relativeTo: baseURL) else {
          throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Ajout du header Authorization
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
          throw APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        // Supposons que UserProfile soit un struct Decodable
          return try JSONDecoder().decode(User.self, from: data)
    }
    
    func clearToken() {
        jwtToken = nil
    }
}

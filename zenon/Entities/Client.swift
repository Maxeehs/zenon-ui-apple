import Foundation

struct Client: Identifiable, Codable {
    let id: Int
    let nom: String
    let email: String
    let owner: User
}

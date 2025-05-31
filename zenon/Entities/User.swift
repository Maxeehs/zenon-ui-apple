import Foundation

struct User: Decodable {
    let id: Int
    let dateCreation: Date
    let email: String
    let password: String
    let lastname: String
    let firstname: String
    let active: Bool
    let role: Array<String>
}

import Foundation

/// Service pour les validations courantes
struct ValidationService {
  /// Vérifie qu’une chaîne correspond à un format d’e-mail standard.
  static func isValidEmail(_ email: String) -> Bool {
    let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
    return NSPredicate(format: "SELF MATCHES %@", pattern)
      .evaluate(with: email)
  }
}

import Foundation
import Security

/// Un petit wrapper pour stocker / lire / supprimer des données (Data) dans le Keychain.
struct KeychainHelper {
  
    /// Sauvegarde les `data` dans le Keychain pour un service et un compte donnés.
    /// Si un élément existe déjà, il est supprimé (SecItemDelete) avant d'ajouter la nouvelle entrée.
    static func save(_ data: Data, service: String, account: String) -> OSStatus {
        // 1. Construire le dictionnaire de requête pour Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        // 2. Supprime l'ancienne entrée, s'il y en a une
        SecItemDelete(query as CFDictionary)
        // 3. Ajoute la nouvelle
        return SecItemAdd(query as CFDictionary, nil)
    }
  
    /// Lit les données (Data) du Keychain pour un service et un compte donnés.
    /// Renvoie nil si rien n'est trouvé ou en cas d'erreur.
    static func read(service: String, account: String) -> Data? {
        // 1. Construire la requête pour récupérer l'élément
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        // 2. Tenter de lire
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else {
            return nil
        }
        return result as? Data
    }
  
    /// Supprime l'entrée du Keychain pour un service et un compte donnés.
    static func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

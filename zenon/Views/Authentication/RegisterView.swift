import SwiftUI

struct RegisterView: View {
  @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss // Pour fermer la modal sur macOS
  
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var firstname: String = ""
  @State private var lastname: String = ""
  @State private var confirmPassword: String = ""
  @State private var errorMessage: String? = nil
  @State private var isLoading: Bool = false
  
  var body: some View {
      VStack(spacing: 20) {
          Text("Inscription")
              .font(.system(size: 34, weight: .bold))
          
          // Champ Email
          VStack(alignment: .leading, spacing: 4) {
              Text("Adresse e-mail")
                  .font(.headline)
              TextField("exemple@domaine.com", text: $email)
                  .textFieldStyle(.roundedBorder)
                  .padding(.vertical, 4)
          }
          .padding(.horizontal)
        
          // Champ Mot de passe
          VStack(alignment: .leading, spacing: 4) {
              Text("Mot de passe")
                  .font(.headline)
              SecureField("••••••••", text: $password)
                  .textFieldStyle(.roundedBorder)
                  .padding(.vertical, 4)
          }
          .padding(.horizontal)
          
          // Champ Confirmation du mot de passe
          VStack(alignment: .leading, spacing: 4) {
              Text("Confirmer le mot de passe")
                  .font(.headline)
              SecureField("••••••••", text: $confirmPassword)
                  .textFieldStyle(.roundedBorder)
                  .padding(.vertical, 4)
          }
          .padding(.horizontal)
          
          // Message d'erreur, si besoin
          if let error = errorMessage {
              Text(error)
                  .foregroundColor(.red)
                  .multilineTextAlignment(.center)
                  .padding(.horizontal)
          }
          
          // Bouton "S'inscrire"
          Button {
              Task {
                  await registerAction()
              }
          } label: {
              if isLoading {
                  ProgressView()
                      .controlSize(.small)
              } else {
                  Text("S'inscrire")
              }
          }
          .buttonStyle(.borderedProminent)
          .disabled(
              email.isEmpty ||
              password.isEmpty ||
              confirmPassword.isEmpty ||
              isLoading
          )
          .padding(.top, 8)
          
          // Bouton "Annuler" pour fermer la sheet
          Button("Annuler") {
              dismiss()
          }
          .buttonStyle(.plain)
          .padding(.top, 4)
          
          Spacer()
      }
      .padding()
      .frame(minWidth: 400, maxWidth: 500, minHeight: 480, maxHeight: 580)
  }
  
    private func registerAction() async {
        // 1. Vérifier que les mots de passe correspondent
        guard password == confirmPassword else {
            errorMessage = "Les mots de passe ne correspondent pas."
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        let result = await session.register(email: email, password: password, firstname: firstname, lastname: lastname)
        isLoading = false
        
        if let message = result {
            // L'API renvoie un message (succès ou erreur), on l'affiche
            errorMessage = message
        } else {
            // Inscription réussie (API ne renvoyait pas forcément de JWT)
            // On ferme simplement la fenêtre d'inscription
            dismiss()
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(SessionStore())
        .frame(width: 480, height: 540)
}

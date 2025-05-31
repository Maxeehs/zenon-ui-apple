import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
  
    // États locaux pour l'email et le mot de passe
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
  
    // Si vous proposez à l'utilisateur d'aller sur la vue d'inscription
    @State private var showRegister: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Connexion")
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
            
            // Champ Mot de passe (SecureField masque le texte)
            VStack(alignment: .leading, spacing: 4) {
                Text("Mot de passe")
                    .font(.headline)
                SecureField("••••••••", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .padding(.vertical, 4)
            }
            .padding(.horizontal)
            
            // Message d'erreur, si applicable
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Bouton Se connecter
            Button {
                Task {
                    await loginAction()
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Se connecter")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.isEmpty || isLoading)
            .padding(.top, 8)
            
            // Lien vers l'inscription
            HStack {
                Text("Pas encore de compte ?")
                    .font(.footnote)
                Button("S'inscrire") {
                    showRegister = true
                }
                .buttonStyle(.plain)
                .font(.footnote)
            }
            .padding(.top, 4)
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, maxWidth: 500, minHeight: 400, maxHeight: 500)
        // Présente RegisterView en sheet modale
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(session)
        }
    }
    
    private func loginAction() async {
        // Réinitialiser l'erreur
        errorMessage = nil
        isLoading = true
    
        // Appel au SessionStore.login qui renvoie une String? (message d'erreur ou nil)
        let error = await session.login(email: email, password: password)
        if let err = error {
            errorMessage = err
        }
    
        isLoading = false
        // Si session.isAuthenticated est passé à true, MyApp affichera ContentView automatiquement
  }
}

#Preview {
    LoginView()
        .environmentObject(SessionStore())
        .frame(width: 480, height: 420)
}

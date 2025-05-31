import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Bienvenue, \(session.userEmail ?? "utilisateur") !")
                .font(.system(size: 28, weight: .semibold))
                .padding(.top, 20)
            
            Button("Se déconnecter") {
                session.signOut()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer()
        }
        .frame(minWidth: 400, maxWidth: 600, minHeight: 300, maxHeight: 400)
        // Vous pouvez remplacer ce Spacer par votre UI principale une fois connecté,
        // par exemple un List ou n'importe quel autre contenu.
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionStore())
        .frame(width: 500, height: 350)
}

//
//  LoginView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 31/12/2024.
//
import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @EnvironmentObject private var appStateStore: AppState.Store
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            headerView
            Spacer()
            SignInWithAppleButton(
                .signUp,
                onRequest: { request in
                    request.requestedScopes = [.email]
                },
                onCompletion: { result in
                    handleAppleLogin(result: result)
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            
            Spacer()
            
            Text("By creating your account, you agree to Mellow's Terms & Conditions and Privacy Policy.")
                .multilineTextAlignment(.center)
                .font(.main14)
                .foregroundColor(.slateGray)
                .padding(.vertical, 32)
        }
        .padding(.horizontal, 16)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Sign-Up Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
//            closeButton
            
            Spacer()
            
            Text("Sign Up")
                .font(.main18)
                .foregroundColor(.white)
            
            Spacer()
            
            Spacer().frame(width: 14)
        }
        .padding(16)
    }
    
    private var closeButton: some View {
        Button(action: {
        }) {
            Image(.arrowLeft)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(height: 14)
        }
    }
    
    private func handleAppleLogin(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userID = appleIDCredential.user
                let email = appleIDCredential.email ?? ""
                appStateStore.dispatch(.saveCrenentials(usedID: userID, fullName: "", email: email))
            }
        case .failure(let error):
            alertMessage = "Login with Apple failed: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

#Preview {
    SignUpView()
}

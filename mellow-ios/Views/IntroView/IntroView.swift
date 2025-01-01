//
//  IntroView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import SwiftUI
import AuthenticationServices

struct IntroView: View {
    @EnvironmentObject private var appStateStore: AppState.Store

    let imageResource: ImageResource
    let text: String
    let onStartForFree: () -> Void

    @State private var showAlert = false
    @State private var alertMessage = ""

    var attributedText: AttributedString {
        AttributedString(text)
            .styled(
                for: "your kid",
                foregroundColor: .softPeriwinkle,
                font: .main24
            )
    }

    var body: some View {
        VStack {
            Spacer()

            Image(imageResource)
                .resizable()
                .frame(width: 200, height: 200)

            Text(attributedText)
                .font(.main24)
                .lineSpacing(10)
                .multilineTextAlignment(.center)
                .padding(.minimum(64, 48))

            Spacer()

            VStack {
                SubmitButton(title: "Start for free", action: onStartForFree)
                    .padding(.bottom)
                    .frame(height: 48)

                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.email]
                    },
                    onCompletion: { result in
                        handleAppleLogin(result: result)
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 48)
                .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .background(.gunmetalBlue)
        .foregroundStyle(.white)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Sign-In Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
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
    IntroView(imageResource: .kidoHer,
              text: "Science based sleep program that adapts to  your kid.") {
        print("Start her")
    }
}

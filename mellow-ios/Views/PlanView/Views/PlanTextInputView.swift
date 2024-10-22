//
//  PlanTextInputView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import SwiftUI

struct PlanTextInputView: View {
    enum FocusField: Hashable {
        case field
    }
    
    @Binding var value: String
    
    @FocusState private var focusedField: FocusField?
    
    let headlineText: String
    let placeholderText: String
    let submitText: String
    @State private var inputText = ""
    
    var body: some View {
        VStack {
            Spacer()
            Text(headlineText)
                .font(.main24)
                .multilineTextAlignment(.center)
                .padding()
            TextField(placeholderText, text: $inputText)
                .focused($focusedField, equals: .field)
                .autocorrectionDisabled()
                .multilineTextAlignment(.center)
                .font(.main64)
                .padding()
                .tint(.black)
                .onAppear {
                    self.focusedField = .field
                }
            Spacer()
            SubmitButton(title: submitText) {
                focusedField = nil
                withAnimation {
                    value = inputText
                }
            }
            .opacity(inputText.isEmpty ? 0.0 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: inputText.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom)
        }
    }
}

#Preview {
    PlanTextInputView(value: .init(get: { "" }, set: { _ in }),
                      headlineText: "How do you call your child?",
                      placeholderText: "name",
                      submitText: "Continue")
}

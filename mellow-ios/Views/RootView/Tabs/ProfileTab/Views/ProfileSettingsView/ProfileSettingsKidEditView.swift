//
//  ProfileSettingsKidEditView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 09/11/2024.
//

import SwiftUI

struct ProfileSettingsKidEditView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    var kid: Kid
    
    // MARK: - State Properties
    @State private var name: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var showingAlert: Bool = false
    
    var body: some View {
        Form {
            // Name Input Field
            TextField("Enter your name", text: $name)
                .autocapitalization(.words)
                .disableAutocorrection(true)
            
            // Date of Birth Picker
            DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                .datePickerStyle(.wheel)
            
            // Section for Submit Button
            Section {
                Button(action: {
                    // Validate the form
                    if name.trimmingCharacters(in: .whitespaces).isEmpty {
                        showingAlert = true
                    } else {
                        // Handle form submission
                        handleSubmit()
                    }
                }) {
                    Text("Submit")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Invalid Input"),
                        message: Text("Please enter your name."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        .background(Color.deepNight)
        .foregroundStyle(.black)
        .onAppear {
            name = kid.name
            dateOfBirth = kid.dateOfBirth ?? .now
        }
    }
    
    // MARK: - Functions
    private func handleSubmit() {
        // Convert date to a readable format
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dobString = formatter.string(from: dateOfBirth)
        
        // For demonstration, we'll just print the values
        print("Name: \(name)")
        print("Date of Birth: \(dobString)")
        appState.databaseService.updateKid(kid: kid, name: name, dateOfBirth: dateOfBirth, context: modelContext)
    }
}

struct ProfileSettingsKidEditView_Previews: PreviewProvider {
    static var previews: some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        // Create a sample Kid instance
        let kid1 = Kid(name: "Alice", dateOfBirth: formatter.date(from: "2015/06/15")!)
        
        return ProfileSettingsKidEditView(kid: kid1)
            .environmentObject(AppState())
    }
}

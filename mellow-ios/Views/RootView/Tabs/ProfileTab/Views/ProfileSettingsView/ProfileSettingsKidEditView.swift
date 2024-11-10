//
//  ProfileSettingsKidEditView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 09/11/2024.
//

import SwiftUI

struct ProfileSettingsKidEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var appState: AppState
    var kid: Kid
    
    // MARK: - State Properties
    @State private var name: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var showingAlert: Bool = false
    @State private var saveButtonEnabled: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            headerView
            kidDetails
            Spacer()
        }
        .toolbar(.hidden)
        .background(Color.deepNight)
        .onChange(of: name) {
            if name != kid.name, !name.isEmpty, !saveButtonEnabled {
                saveButtonEnabled = true
            } else if kid.name == name && dateOfBirth == kid.dateOfBirth {
                saveButtonEnabled = false
            }
        }
        .onChange(of: dateOfBirth) {
            if dateOfBirth != kid.dateOfBirth, !saveButtonEnabled {
                saveButtonEnabled = true
            } else if kid.name == name && dateOfBirth == kid.dateOfBirth {
                saveButtonEnabled = false
            }
        }
        .onAppear {
            name = kid.name
            dateOfBirth = kid.dateOfBirth ?? .now
        }
    }
    
    // MARK: - Header View
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(.arrowLeft)
                .renderingMode(.template)
                .resizable()
                .foregroundColor(.white)
                .frame(width: 8, height: 14)
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            appState
                .databaseService
                .updateKid(kid: kid,
                           name: name,
                           dateOfBirth: dateOfBirth,
                           context: modelContext)
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Save")
                .font(.main16)
                .foregroundStyle(saveButtonEnabled ? .primary300 : .placeholder)
        }
        .opacity(saveButtonEnabled ? 1 : 0.3)
        .disabled(!saveButtonEnabled)
    }
    
    private var headerView: some View {
        HStack {
            backButton
            Spacer()
            Text(kid.name)
                .font(.main18)
                .foregroundColor(.white)
            Spacer()
            saveButton
        }
        .padding(16)
    }
    
    private var kidDetails: some View {
        VStack(spacing: 1) {
            HStack {
                Text("Name")
                    .font(.main16)
                Spacer()
                TextField("", text: $name)
                    .font(.main16)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(Color.placeholder)
                    .containerRelativeFrame(.horizontal, count: 6, span: 2, spacing: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            .background(Color.gunmetalBlue)
            
            VStack {
                Text("Birthdate")
                    .font(.main16)
                    .padding(.vertical, 16)
                DatePicker(selection: $dateOfBirth,
                           in: Date.distantPast...Date.now,
                           displayedComponents: .date,
                           label: { EmptyView() })
                .datePickerStyle(.wheel)
                .labelsHidden()
                .datePickerColor(invert: true,
                                 multiplyColor: .white)
            }
            .frame(maxWidth: .infinity)
            .background(Color.gunmetalBlue)
        }
        .foregroundStyle(Color.white)
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

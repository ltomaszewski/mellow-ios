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
    @EnvironmentObject var appStateStore: AppState.Store
    let kid: Kid
    
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
            dateOfBirth = kid.dateOfBirth
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
            kid.name = name
            kid.dateOfBirth = dateOfBirth
            appStateStore.dispatch(.kidOperation(.update(kid.id), kid, modelContext))
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
}

struct ProfileSettingsKidEditView_Previews: PreviewProvider {
    static var previews: some View {
        // Initialize a DateFormatter for the date of birth
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        // Create a sample date of birth
        guard let dateOfBirth = dateFormatter.date(from: "2015/06/15") else {
            fatalError("Failed to create date from string.")
        }
        
        // Initialize a Calendar instance to set specific times
        let calendar = Calendar.current
        
        // Create sleepTime (e.g., 8:30 PM)
        guard let sleepTime = calendar.date(bySettingHour: 20, minute: 30, second: 0, of: Date()) else {
            fatalError("Failed to create sleepTime.")
        }
        
        // Create wakeTime (e.g., 7:00 AM)
        guard let wakeTime = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) else {
            fatalError("Failed to create wakeTime.")
        }
        
        // Create a sample Kid instance with all required fields
        let kid1 = Kid(name: "Alice", dateOfBirth: dateOfBirth, sleepTime: sleepTime, wakeTime: wakeTime)
        
        // Return the ProfileSettingsKidEditView with the sample Kid
        return ProfileSettingsKidEditView(kid: kid1)
    }
}

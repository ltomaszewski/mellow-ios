//
//  SleepScoreItemView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 19/10/2024.
//

import SwiftUI

// This view component is a generalized display for either session-related information (e.g., when the next session should start)
// or score-related data, depending on the input provided. It handles both use cases: showing a score or a button to initiate a session.
struct SessionInfoView: View {
    var infoType: InfoType       // Enum representing different information categories (e.g., "Score", "Next Session")
    var score: Int?              // Optional main score (shown on the left)
    var scoreText: String?       // Optional main score text (shown on the left, used if numeric score is not provided)
    var rightText: String?       // Optional text (shown on the right)
    var rightScore: Int?         // Optional secondary score (shown on the right)
    
    var buttonImage: ImageResource?     // Optional image name for the button (from the asset catalog)
    var buttonAction: (() -> Void)?     // Optional action closure executed when the button is tapped

    // The view's body which contains two vertically-aligned sections (left and right)
    var body: some View {
        HStack(alignment: buttonImage != nil ? .center : .bottom) {
            // Left side - displays the info type title and optional score
            VStack(alignment: .leading, spacing: 3) {
                // Display the info type title from the InfoType enum
                Text(infoType.title())
                    .font(.main18)
                    .foregroundColor(.slateGray)
                
                if score != nil || scoreText != nil {
                    // Display either the numeric score (if provided) or the scoreText inline
                    Text(score != nil ? "\(score!)%" : scoreText ?? "")
                        .font(.main32)
                        .foregroundColor(.white)
                }
            }
            Spacer() // Spacer to push the right section to the far right

            // Right side - displays either the rightLabel and rightScore, or a button
            VStack(alignment: .trailing) {
                // If a right title is provided, display it
                if let rightText {
                    Text(rightText)
                        .font(.main18)
                        .foregroundColor(.slateGray)
                }
                
                // If a right score is provided, display it
                if let rightScore {
                    Text("\(rightScore)%")
                        .font(.main20)
                        .foregroundColor(.white)
                    
                } else if let buttonImage, let buttonAction {
                    // If no rightText and rightScore but buttonImageName and buttonAction are provided, display the button with the image
                     Button(action: {
                         buttonAction() // Execute the provided action on tap
                     }) {
                         Image(buttonImage)
                             .resizable()
                             .scaledToFit()
                             .frame(height: 48)
                     }
                 
                }
            }
        }
        .padding()
        .background(.darkBlueGray)
        .cornerRadius(12)
    }
}

// Extension for the SessionInfoView to define the types of information
extension SessionInfoView {
    // Enum representing different types of information that can be displayed
    enum InfoType: String {
        case score = "Score"                      // Overall score
        case napTimes = "Nap times"               // Number of naps
        case sleepDuration = "Sleep duration"     // Total sleep duration
        case wakeupTime = "Wakeup time"           // Wakeup time
        case consistency = "3-day consistency"    // Consistency over 3 days
        case nextSession = "Next sleep"   // Next session (represented by the button)

        // Method to return the raw value (title) of each enum case
        func title() -> String {
            return self.rawValue
        }
    }
}

// Preview section for SwiftUI previews, showcasing different configurations of the SleepScoreView
#Preview {
    VStack {
        // Example with a main score and right-hand title
        SessionInfoView(infoType: .score, score: 86, buttonImage: .buttonStartnow) {
            print("Start Now")
        }
        
        // Example with a main score and right-hand title
        SessionInfoView(infoType: .score, score: 86, rightText: "Great")
        
        // Example with only a right-side score and no main score
        SessionInfoView(infoType: .napTimes, rightScore: 12)
    }
}

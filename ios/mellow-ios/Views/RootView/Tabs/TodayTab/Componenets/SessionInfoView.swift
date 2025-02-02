//
//  SleepScoreItemView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 19/10/2024.
//

import SwiftUI

struct SessionInfoView: View {
    /// Enum representing different information categories for the left side.
    enum InfoType: Equatable {
        case score                             // Overall score
        case napTimes                          // Number of naps
        case sleepDuration                     // Total sleep duration
        case wakeupTime                        // Wakeup time
        case consistency                       // Consistency over 3 days
        case nextSession                       // Next session (represented by the button)
        case custom(String)                    // Custom case with an associated string value

        /// Returns the title for each InfoType.
        func title() -> String {
            switch self {
            case .score:
                return "Score"
            case .napTimes:
                return "Nap times"
            case .sleepDuration:
                return "Sleep duration"
            case .wakeupTime:
                return "Wakeup time"
            case .consistency:
                return "3-day consistency"
            case .nextSession:
                return "Next sleep"
            case .custom(let value):
                return value
            }
        }
    }
    
    /// Represents individual content items that can appear on the right side of the view.
    enum RightContentItem {
        case text(String)
        case score(Int)
        case button(image: ImageResource, action: () -> Void)
    }
    
    // MARK: - Properties
    
    var infoType: InfoType                 // The type of information to display on the left
    var leftScore: Int?                    // Optional main score (shown below the title)
    var leftScoreText: String?             // Optional main score text (shown below the title)
    var rightContent: [RightContentItem]?  // Array of content items to display on the right side

    // MARK: - Body
    
    var body: some View {
        HStack(alignment: (infoType == .score ? .bottom : .center)) {
            // Left Side
            VStack(alignment: .leading, spacing: 3) {
                Text(infoType.title())
                    .font(.main18)
                    .foregroundColor(.slateGray)
                
                if let score = leftScore {
                    Text("\(score)%")
                        .font(.main32)
                        .foregroundColor(.white)
                } else if let scoreText = leftScoreText {
                    Text(scoreText)
                        .font(.main32)
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            // Right Side
            VStack(alignment: .trailing, spacing: 3) {
                if let rightContent {
                    ForEach(rightContent.indices, id: \.self) { index in
                        switch rightContent[index] {
                        case .text(let text):
                            Text(text)
                                .font(.main18)
                                .foregroundColor(.slateGray)
                        case .score(let score):
                            Text("\(score)%")
                                .font(.main20)
                                .foregroundColor(.white)
                        case .button(let image, let action):
                            Button(action: action) {
                                Image(image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 48)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.darkBlueGray)
        .cornerRadius(12)
    }
}

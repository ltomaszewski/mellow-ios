import SwiftUI
import PlaygroundSupport

// Create a TextField application that takes input text, and if the text equals “lol”, an additional icon will be presented based on the state. To achieve that, we will use AppState where we will hold a boolean that indicates if the text matches “lol”. Then we have a store where we save the current state of the text, move on to State where we define all possible states for the screen, and last but not least, Action. Action one is textHasChanged

// Main protocol for reducer for easier mocking and access isolation
protocol ReducerProtocol {
    associatedtype ReducerState
    associatedtype ReducerAction

    func reduce(state: inout ReducerState, action: ReducerAction)
}

// Sate of the view with textfield, possible Actions
struct LolState {
    enum Action {
        case valueChanged(String)
    }
    var value: String
}

// Reducer to update state base on action
extension LolState {
    struct Reducer: ReducerProtocol {
        func reduce(state: inout LolState, action: Action) {
            switch action {
            case .valueChanged(let value):
                state.value = value
            }
        }
    }
}

// Store to hold latest value of the state and make it possible to subscribe inside SwiftUI
extension LolState {
    class Store: ObservableObject {
        @Published private(set) var state: LolState
        private let reducer = Reducer()
        
        init(state: LolState) {
            self.state = state
        }
        
        func dispatch(_ action: LolState.Action) {
            reducer.reduce(state: &state, action: action)
        }
    }
}

// Main AppState
struct AppState {
    enum Action {
        case lol(LolState.Action)
    }
    var lolState: LolState
    var isLol: Bool = false
}

// Reducer to appState
extension AppState {
    struct Reducer: ReducerProtocol {
        let lolReducer: LolState.Reducer
        
        init(lolReducer: LolState.Reducer) {
            self.lolReducer = lolReducer
        }
        
        func reduce(state: inout AppState, action: Action) {
            switch action {
            case .lol(let lolAction):
                lolReducer.reduce(state: &state.lolState, action: lolAction)
            }
        }
    }
}

// Store to hold latest value of the state and make it possible to subscribe inside SwiftUI
extension AppState {
    class Store: ObservableObject {
        @Published private(set) var state: AppState
        private let reducer = Reducer(lolReducer: LolState.Reducer())
        
        init(state: AppState) {
            self.state = state
        }
        
        func dispatch(_ action: AppState.Action) {
            reducer.reduce(state: &state, action: action)
        }
    }
}


struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ExampleView()) {
                    Text("Go to Example View")
                }
                NavigationLink(destination: SecondView()) {
                    Text("Go to Second View")
                }
            }
            .navigationTitle("Sample Views")
        }
    }
}

struct ExampleView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .font(.largeTitle)
            Text("This is the Example View.")
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct SecondView: View {
    var body: some View {
        VStack {
            Text("Welcome to the Second View!")
                .font(.largeTitle)
            Text("Enjoy exploring SwiftUI.")
                .foregroundColor(.gray)
        }
        .padding()
    }
}

// Present the ContentView in the playground
PlaygroundPage.current.setLiveView(ContentView().frame(width: 320, height: 480))

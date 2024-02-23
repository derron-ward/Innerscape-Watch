import SwiftUI
import FirebaseCore

@main
struct Innerscape_Watch_Watch_AppApp: App {
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

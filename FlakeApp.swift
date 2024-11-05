import SwiftUI

// MARK: - App Entry Point
@main
struct FlakeApp: App {
    @State var appManager = FlakeAppManager.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView()
                    .environmentObject(appManager)
            }
        }
    }
}

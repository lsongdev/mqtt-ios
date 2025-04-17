import SwiftUI

@main
struct FlakeApp: App {
    @StateObject private var appManager = FlakeAppManager.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView()
                    .environmentObject(appManager)
            }
        }
    }
}

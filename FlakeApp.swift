import SwiftUI
import BackgroundTasks
import UIKit

// MARK: - App Entry Point
@main
struct FlakeApp: App {
    @StateObject private var appManager = FlakeAppManager.shared
    
    init() {
        // 在应用启动早期注册后台任务
        registerBackgroundTasks()
    }
    
    private func registerBackgroundTasks() {
        let backgroundTaskIdentifier = "flakemq.background.task"
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            // 将任务处理委托给 FlakeAppManager
            FlakeAppManager.shared.handleBackgroundTask(task as! BGProcessingTask)
        }
        print("Background tasks registered at app launch")
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView()
                    .environmentObject(appManager)
            }
        }
    }
}

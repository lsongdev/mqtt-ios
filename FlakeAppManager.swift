import SwiftUI
import UserNotifications
import BackgroundTasks

// MARK: - App Manager
final class FlakeAppManager: ObservableObject {
    // MARK: - Constants
    private enum BackgroundTaskIdentifier {
        static let refresh = "org.lsong.mqtt.refresh"
        static let processing = "org.lsong.mqtt.processing"
    }
    
    // MARK: - Singleton
    static let shared: FlakeAppManager = .init()
    
    // MARK: - Published Properties
    @Published private(set) var servers: [ServerDescription] = []
    @State private var clients: [UUID: MQTTClient] = [:]
    
    func getClient(for server: ServerDescription) -> MQTTClient {
        if let existingClient = clients[server.id] {
            return existingClient
        }
        let client = MQTTClient(server: server)
        clients[server.id] = client
        return client
    }
    
    // MARK: - Private Properties
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private let storageKey = "servers"
    private let backgroundTaskIdentifier = "flakemq.background.task"
    
    // MARK: - Initialization
    init() {
        loadServers()
        setupBackgroundHandling()
        requestNotificationPermission()
        registerBackgroundTasks()
    }
    
    // MARK: - Notification Methods
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限已获取")
            } else if let error = error {
                print("通知权限请求失败: \(error.localizedDescription)")
            }
        }
    }
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Public Methods
    func addServer(_ server: ServerDescription) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.servers.append(server)
            self.saveServers()
        }
    }
    
    func removeServer(at indexSet: IndexSet) {
        servers.remove(atOffsets: indexSet)
        saveServers()
    }
    
    func removeServer(index: Int) {
        servers.remove(at: index)
        saveServers()
    }
    
    func removeServer(server: ServerDescription) {
        removeServer(id: server.id)
    }
    
    func removeServer(id: UUID) {
        guard let index = servers.firstIndex(where: { $0.id == id }) else { return }
        servers.remove(at: index)
        saveServers()
    }
    
    func updateServer(server: ServerDescription) {
        guard let index = servers.firstIndex(where: { $0.id == server.id }) else { return }
        servers[index] = server
        saveServers()
    }
    
    func addDemoServers() {
        let topic = Subscription(name: "test")
        addServer(ServerDescription(host: "broker.emqx.io", port: "1883", subscriptions: [topic]))
        addServer(ServerDescription(host: "broker.hivemq.com", port: "1883", subscriptions: [topic]))
    }
    
    // MARK: - Background Task Registration
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTaskIdentifier.refresh,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTaskIdentifier.processing,
            using: nil
        ) { task in
            self.handleProcessingTask(task: task as! BGProcessingTask)
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // 保持 MQTT 连接
        for client in clients.values {
            if client.connectionState.isConnected {
                client.connect()
            }
        }
        
        // 完成后台任务
        task.setTaskCompleted(success: true)
        
        // 安排下一次刷新
        scheduleAppRefresh()
    }
    
    private func handleProcessingTask(task: BGProcessingTask) {
        // 完成后台任务
        task.setTaskCompleted(success: true)
        // 安排下一次处理
        scheduleProcessingTask()
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: BackgroundTaskIdentifier.refresh)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15分钟后
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("无法安排应用刷新: \(error)")
        }
    }
    
    private func scheduleProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: BackgroundTaskIdentifier.processing)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60) // 30分钟后
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("无法安排处理任务: \(error)")
        }
    }
}

// MARK: - Private Methods
extension FlakeAppManager {
    func loadServers() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let servers = try? JSONDecoder().decode([ServerDescription].self, from: data) else {
            return
        }
        self.servers = servers
    }
    
    func saveServers() {
        guard let data = try? JSONEncoder().encode(servers) else {
            print("Failed to encode servers")
            return
        }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    func setupBackgroundHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBackgroundTransition),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleForegroundTransition),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task scheduled successfully")
        } catch {
            print("Failed to schedule background task: \(error)")
        }
    }
    
    func handleBackgroundTask(_ task: BGProcessingTask) {
        // Create a task assertion to keep the app running longer
        scheduleBackgroundTask() // Schedule the next background task
        
        // Set up a task expiration handler
        task.expirationHandler = {
            // Clean up any unfinished tasks if needed
            print("Background task expired")
        }
    }
    
    @objc func handleBackgroundTransition() {
        // Start a background task to keep the app running longer
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        // Schedule a background processing task
        scheduleBackgroundTask()
        print("App entered background - maintaining MQTT connections")
    }
    
    @objc func handleForegroundTransition() {
        endBackgroundTask()
        print("App entered foreground - checking MQTT connections")
    }
    
    func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}

// MARK: - App Information
extension FlakeAppManager {
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "FlakeMQ"
    }
}

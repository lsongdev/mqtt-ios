import SwiftUI
import UserNotifications

// MARK: - App Manager
final class FlakeAppManager: ObservableObject {
    static let shared: FlakeAppManager = .init()
    
    // MARK: - Published Properties
    @Published private(set) var servers: [ServerDescription] = []
    @State private var clients: [UUID: MQTTClient] = [:]
    
    private let storageKey = "servers"
    
    func getClient(for server: ServerDescription) -> MQTTClient {
        if let existingClient = clients[server.id] {
            return existingClient
        }
        let client = MQTTClient(server: server)
        clients[server.id] = client
        return client
    }
    
    // MARK: - Initialization
    init() {
        loadServers()
        requestNotificationPermission()
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

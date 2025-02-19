import SwiftUI

// MARK: - App Manager
final class FlakeAppManager: ObservableObject {
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
    
    // MARK: - Initialization
    init() {
        loadServers()
        setupBackgroundHandling()
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
        addServer(ServerDescription(host: "broker.emqx.io", port: "1883"))
        addServer(ServerDescription(host: "broker.hivemq.com", port: "1883"))
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
    
    @objc func handleBackgroundTransition() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    @objc func handleForegroundTransition() {
        endBackgroundTask()
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

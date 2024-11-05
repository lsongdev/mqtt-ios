//
//  ServerViewModel.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI

// MARK: - View Models
class FlakeAppManager: ObservableObject {
    static var shared: FlakeAppManager = .init()
    private let storage: ServerDescriptionStorage = UserDefaultsStorage()
    @Published var servers: [ServerDescription] = []
    
    init() {
        loadServers()
    }
    
    func addServer(_ server: ServerDescription) {
        DispatchQueue.main.async {
            self.servers.append(server)
            self.objectWillChange.send()
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
        if let index = servers.firstIndex(where: { $0.id == id }) {
            servers.remove(at: index)
            saveServers()
        }
    }
    
    func updateServer(server: ServerDescription) {
        if let index = self.servers.firstIndex(where: { $0.id == server.id }) {
            self.servers[index] = server
            self.saveServers()
        }
    }
    
    func loadServers() {
        servers = storage.load()
    }
    
    func saveServers() {
        storage.save(servers)
    }
    func addDemoServers() {
        addServer(ServerDescription(host: "broker.emqx.io", port: "1883"))
        addServer(ServerDescription(host: "broker.hivemq.com", port: "1883"))
    }
}

// MARK: - Storage
protocol ServerDescriptionStorage {
    func save(_ servers: [ServerDescription])
    func load() -> [ServerDescription]
}

struct UserDefaultsStorage: ServerDescriptionStorage {
    private let key = "servers"
    
    func save(_ servers: [ServerDescription]) {
        if let data = try? JSONEncoder().encode(servers) {
            print("save \(data)")
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func load() -> [ServerDescription] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let servers = try? JSONDecoder().decode([ServerDescription].self, from: data)
        else {
            return []
        }
        return servers
    }
}

extension FlakeAppManager {
    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "PicoVPN"
    }
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    }
}

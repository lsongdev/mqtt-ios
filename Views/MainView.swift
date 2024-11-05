import SwiftUI
import Combine

struct MainView: View {
    @StateObject private var appManager = FlakeAppManager.shared
    @State private var clients: [UUID: MQTTClientManager] = [:]
    @State private var selectedServer: ServerDescription?
    @State private var showingServer = false
    @State private var showingWelcome = false
    @State private var showingSettings = false
    @State private var searchText = ""
    
    func getClient(for server: ServerDescription) -> MQTTClientManager {
        if let existingClient = clients[server.id] {
            return existingClient
        }
        let client = MQTTClientManager(server: server)
        clients[server.id] = client
        return client
    }
    
    // Filtered servers based on search text
    private var filteredServers: [ServerDescription] {
        if searchText.isEmpty {
            return appManager.servers
        }
        return appManager.servers.filter { server in
            server.name.localizedCaseInsensitiveContains(searchText) ||
            server.host.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            Section ("Servers") {
                ForEach(filteredServers) { server in
                    let client = getClient(for: server)
                    NavigationLink(destination: ServerDetailView(
                        client: client
                    )) {
                        ServerRowView(client: client)
                    }
                    .contextMenu {
                        // Connect/Disconnect button
                        if client.connectionState.canConnect {
                            Button(action: { client.connect() }) {
                                Label("Connect", systemImage: "link")
                            }
                        } else {
                            Button(action: { client.disconnect() }) {
                                Label("Disconnect", systemImage: "link.slash")
                            }
                        }
                        Button(action: { selectedServer = server }) {
                            Label("Edit Server", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            client.disconnect()
                            appManager.removeServer(server: server)
                        }) {
                            Label("Delete Server", systemImage: "trash")
                        }
                    }
                }
                .onDelete { indexSet in
                    appManager.removeServer(at: indexSet)
                }
                if appManager.servers.isEmpty {
                    Text("No servers found. Add one by tapping the plus (+) button in the top right corner.")
                        .foregroundColor(.secondary)
                }
            }
        }
        .searchable(text: $searchText)
        .refreshable {
            appManager.loadServers()
        }
        .navigationTitle(appManager.appName)
        .navigationBarItems(trailing: HStack {
            Button(action: { showingServer = true }) {
                Image(systemName: "plus")
            }
            Button(action: { showingSettings = true }) {
                Image(systemName: "gear")
            }
        })
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Image(systemName: "snowflake")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingWelcome) {
            WelcomeView()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingServer) {
            ServerFormView { newServer in
                appManager.addServer(newServer)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(item: $selectedServer) { server in
            ServerFormView(server: server) { updatedServer in
                appManager.updateServer(server: updatedServer)
                let client = getClient(for: server)
                client.server = updatedServer
                
            }
        }
        .onAppear {
            showingWelcome = appManager.servers.isEmpty
        }
        
    }
}

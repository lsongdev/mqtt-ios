import SwiftUI
import Combine

struct MainView: View {
    @EnvironmentObject var appManager: FlakeAppManager
    
    @State private var selectedServer: ServerDescription?
    @State private var showingServer = false
    @State private var showingWelcome = false
    @State private var showingSettings = false
    @State private var searchText = ""
    
    
    
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
                     let client = appManager.getClient(for: server)
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
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(item: $selectedServer) { server in
            ServerFormView(server: server) { updatedServer in
                appManager.updateServer(server: updatedServer)
                let client = appManager.getClient(for: server)
                client.server = updatedServer
                
            }
        }
        .onAppear {
            showingWelcome = appManager.servers.isEmpty
        }
        
    }
}


struct ServerRowView: View {
    @ObservedObject var client: MQTTClient
    
    private var statusColor: Color {
        switch client.connectionState {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .secondary
        case .error: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator dot
           Circle()
               .fill(statusColor)
               .frame(width: 8, height: 8)
            // Server info
            VStack(alignment: .leading, spacing: 2) {
                Text(client.server.name.isEmpty ? client.server.host : client.server.name)
                    .font(.headline)
                
                Text("\(client.server.host):\(String(client.server.port))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(client.messages.count)")
                .foregroundColor(.secondary)
            
        }
    }
}

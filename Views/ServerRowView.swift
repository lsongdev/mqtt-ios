//
//  ServerRowView.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI

struct ServerRowView: View {
    @ObservedObject var client: MQTTClientManager
    
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

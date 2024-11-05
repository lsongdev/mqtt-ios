//
//  StatusView.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI


// MARK: - Status View
struct StatusView: View {
    let connectionState: MQTTClient.ConnectionState
    
    var body: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.caption)
                .foregroundColor(statusColor)
        }
    }
    
    private var statusText: String {
        switch connectionState {
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnected: return "Disconnected"
        case .error: return "Error: \(connectionState)"
        }
    }
    
    private var statusColor: Color {
        switch connectionState {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .secondary
        case .error: return .red
        }
    }
}

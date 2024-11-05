//
//  MessageView.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//

import SwiftUI

struct MessageView: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.timestamp, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(message.payload)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .foregroundColor(.primary)
                .padding(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = message.payload
                    }) {
                        Label("Copy Message", systemImage: "doc.on.doc")
                    }
                }
        }
        .padding(12)
        
    }
}


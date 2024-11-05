//
//  SubscriptionView.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI

struct SubscriptionView: View {
    let subscription: Subscription
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(subscription.name)
                .font(.headline)
            Text("QoS: \(subscription.qos)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

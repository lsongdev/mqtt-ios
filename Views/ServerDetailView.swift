//
//  ServerDetailView.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//

import SwiftUI
import Combine

// MARK: - Server Detail View
struct ServerDetailView: View {
    @ObservedObject var appManager: FlakeAppManager = FlakeAppManager.shared
    @ObservedObject var client: MQTTClient
    @State private var showSubscribe = false
    
    var body: some View {
        List {
            Section(header: Text("Connection")) {
                HStack {
                    StatusView(connectionState: client.connectionState)
                    Spacer()
                    if client.connectionState.canConnect {
                        Button("Connect") {
                            client.connect()
                        }
                    } else {
                        Button("Disconnect") {
                            client.disconnect()
                        }
                    }
                }
            }
            
            Section(header: HStack {
                Text("Topics")
                Spacer()
                Button(action: { showSubscribe = true }) {
                    Image(systemName: "plus")
                }
            }) {
                ForEach(client.server.subscriptions) { subscription in
                    NavigationLink(
                        destination: MessagesView(
                            subscription: subscription,
                            messages: client.messages,
                            onPublish: client.publish
                        )
                    ) {
                        SubscriptionView(subscription: subscription)
                    }
                    .contextMenu {
                        Button(action: {
                            client.subscribe(to: subscription.name)
                        }) {
                            Text("Subscribe")
                        }
                        Button(action: {
                            client.unsubscribe(from: subscription.name)
                        }) {
                            Text("Unsubscribe")
                        }
                        Button(role: .destructive, action: {
                            client.messages.clear()
                        }) {
                            Text("Clear Messages")
                        }
                    }
                }
                .onDelete { indexSet in
                    var updatedTopics = client.server.subscriptions
                    for index in indexSet {
                        let subscription = client.server.subscriptions[index]
                        client.unsubscribe(from: subscription.name)
                        updatedTopics.remove(at: index)
                    }
                    client.server.subscriptions = updatedTopics
                    appManager.updateServer(server: client.server)
                }
            }
        }
        .navigationTitle(client.server.displayName)
        .sheet(isPresented: $showSubscribe) {
            NavigationView {
                SubscribeView { topic, qos in
                    client.subscribe(to: topic, qos: qos)
                    client.server.subscriptions.append(Subscription(name: topic, qos: qos))
                    appManager.updateServer(server: client.server)
                }
            }
        }
    }
}


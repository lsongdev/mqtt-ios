//
//  WelcomeView.swift
//  FlakeMQ
//
//  Created by Lsong on 2/18/25.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appManager: FlakeAppManager
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "snowflake")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.blue)
                        .padding(.bottom, 8)
                    
                    VStack(spacing: 4) {
                        Text("Welcome to FlakeMQ")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Lightweight & Powerful MQTT Client")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                                
                VStack(alignment: .leading, spacing: 24) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Real-time Communication")
                                .font(.headline)
                            Text("Fast and reliable MQTT messaging")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "bolt.horizontal.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 8)
                    }
                    
                    Label {
                        VStack(alignment: .leading) {
                            Text("Topic Management")
                                .font(.headline)
                            Text("Easy subscribe and publish")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "list.bullet.rectangle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 8)
                    }
                    
                    Label {
                        VStack(alignment: .leading) {
                            Text("Message Monitoring")
                                .font(.headline)
                            Text("Visual message tracking and history")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "chart.bar.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button {
                    appManager.addDemoServers()
                    dismiss()
                } label: {
                    Text(isLoading ? "Initializing..." : "Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundStyle(.background)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .padding(.horizontal)
                .disabled(isLoading)
            }
            .padding()
            .navigationTitle("Welcome")
            .toolbar(.hidden)
        }
    }
}

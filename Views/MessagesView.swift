//
//  MessagesView.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI

struct MessagesView: View {
    let subscription: Subscription
    let messages: CircularBuffer<Message>
    let onPublish: (Message) -> Void
    @State private var formData: Message = Message.empty
    @State private var showPublishSheet = false
    @State private var isScrolledToBottom = true

    // 过滤当前主题的消息
    private var topicMessages: [Message] {
        messages.filter { $0.topic == subscription.name }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ZStack(alignment: .bottomTrailing) {
                    List {
                        ForEach(topicMessages) { message in
                            MessageView(message: message)
                                .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                .listRowBackground(Color.clear)
                                .id(message.id)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .onChange(of: messages) { _ in
                        if isScrolledToBottom {
                            withAnimation {
                                if let lastId = topicMessages.last?.id {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .simultaneousGesture(
                        DragGesture().onChanged { _ in
                            isScrolledToBottom = false
                        }
                    )
                    .listStyle(PlainListStyle())
                    .background(Color(.systemGroupedBackground))
                    
                    // Scroll to Bottom Button
                    if !isScrolledToBottom && !topicMessages.isEmpty {
                        Button {
                            withAnimation {
                                if let lastId = topicMessages.last?.id {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                    isScrolledToBottom = true
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground))
                                        .shadow(radius: 2)
                                )
                        }
                        .padding([.trailing, .bottom], 16)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            
            // Publisher Panel
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    // Message Input Area
                    HStack(spacing: 8) {
                        Menu {
                            Picker("QoS", selection: $formData.qos) {
                                Text("At most once (0)").tag(0)
                                Text("At least once (1)").tag(1)
                                Text("Exactly once (2)").tag(2)
                            }
                            Toggle("Retain", isOn: $formData.retain)
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.gray)
                        }
                        
                        TextField("Type message", text: $formData.payload)
                            .textFieldStyle(PlainTextFieldStyle())
                            .textInputAutocapitalization(.never)
                        
                        Button(action: { showPublishSheet = true }) {
                            Image(systemName: "chevron.up")
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            guard formData.isValid else {
                                return
                            }
                            onPublish(formData)
                            formData.payload = ""
                            isScrolledToBottom = true
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(formData.isValid ? .accentColor : .gray)
                        }
                        .disabled(!formData.isValid)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))
            .onAppear {
                formData.topic = subscription.name
            }
        }
        .navigationTitle(subscription.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPublishSheet) {
            PublishView(
                message: formData,
                onPublish: onPublish
            )
            .presentationDetents([.medium, .large])
        }
    }
}

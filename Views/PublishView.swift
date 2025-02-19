//
//  PublishView.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI


// MARK: - Publish Sheet
struct PublishView: View {
    @Environment(\.dismiss) var dismiss
    @State private var formData: Message
    private let onPublish: (Message) -> Void
    
    init(message: Message = Message.empty, onPublish: @escaping (Message) -> Void) {
        self.formData = message
        self.onPublish = onPublish
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    TextField("Topic", text: $formData.topic)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    
                    
                    Picker("QoS", selection: $formData.qos) {
                        Text("At most once (0)").tag(0)
                        Text("At least once (1)").tag(1)
                        Text("Exactly once (2)").tag(2)
                    }
                    
                    Toggle("Retain Message", isOn: $formData.retain)
                    
                    Section("Message") {
                        TextEditor(text: $formData.payload)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 100)
                            .textInputAutocapitalization(.never)
                    }
                    
                    
                }
            }
            .navigationTitle("Publish Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        onPublish(formData)
                        dismiss()
                    }
                    .disabled(!formData.isValid)
                }
            }
        }
    }
}

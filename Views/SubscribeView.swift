//
//  SubscribeView.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI


struct SubscribeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var topic: String = ""
    @State private var qos: Int = 0
    
    let onSubscribe: (String, Int) -> Void
    
    var body: some View {
        Form {
            Section {
                TextField("Topic", text: $topic)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                
                Picker("QoS", selection: $qos) {
                    Text("At most once (0)").tag(0)
                    Text("At least once (1)").tag(1)
                    Text("Exactly once (2)").tag(2)
                }
            } footer: {
                Text("Topic Examples:\n# - Single level wildcard\n+ - Multi level wildcard")
                    .font(.caption)
            }
        }
        .navigationTitle("Subscribe to Topic")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Subscribe") {
                    onSubscribe(topic, qos)
                    dismiss()
                }
                .disabled(topic.isEmpty)
            }
        }
    }
}

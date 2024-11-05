import SwiftUI
import SwiftUIX

// MARK: - Server Form View
struct ServerFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State var formData: ServerDescription
    private let onSave: (ServerDescription) -> Void
    
    init(
        server: ServerDescription = ServerDescription.empty,
        onSave: @escaping (ServerDescription) -> Void
    ) {
        self.onSave = onSave
        self.formData = server
    }
    var body: some View {
            NavigationView {
                Form {
                    serverDetailsSection
                    authenticationSection
                    clientIdSection
                }
                .navigationTitle("Edit Server")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            onSave(formData)
                            dismiss()
                        }
                        .disabled(!formData.isValid)
                    }
                }
            }
        }
        
        private var serverDetailsSection: some View {
            Section(header: Text("Server Details")) {
                InputField("Name", text: $formData.name, placeholder: "(Optional)")
                    .textInputAutocapitalization(.never)
                
                InputField("Hostname", text: $formData.host)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                InputField("Port", text: $formData.port)
                    .keyboardType(.numberPad)
                
                Picker(selection: $formData.protocolVersion, label: Text("Version")) {
                    ForEach(MQTTProtocolVersion.allCases, id: \.self) { version in
                        Text(version.description).tag(version)
                    }
                }
                
                Toggle("Use TLS", isOn: $formData.useTLS)
                
                Toggle("Use WebSocket", isOn: $formData.useWebSocket)
                
                if formData.useWebSocket {
                    InputField("WebSocket Path", text: $formData.webSocketPath)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
            }
        }
        
        private var authenticationSection: some View {
            Section(header: Text("Authentication"), footer: Text("Leave blank if not required")) {
                InputField("Username", text: $formData.username)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                InputField("Password", text: $formData.password)
            }
        }
        
        private var clientIdSection: some View {
            Section(header: Text("Client Id")) {
                InputField("Client ID", text: $formData.clientId, placeholder: "(Optional)")
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            }
        }
}

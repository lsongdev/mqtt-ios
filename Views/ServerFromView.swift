import SwiftUI

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
                TextField("Name (Optional)", text: $formData.name)
                    .textInputAutocapitalization(.never)
                
                TextField("Hostname", text: $formData.host)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                TextField("Port", text: $formData.port)
                    .keyboardType(.numberPad)
                
                Picker(selection: $formData.protocolVersion, label: Text("Version")) {
                    ForEach(MQTTProtocolVersion.allCases, id: \.self) { version in
                        Text(version.description).tag(version)
                    }
                }
                
                Toggle("Use TLS", isOn: $formData.useTLS)
            }
        }
        
        private var authenticationSection: some View {
            Section(header: Text("Authentication"), footer: Text("Leave blank if not required")) {
                TextField("Username", text: $formData.username)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $formData.password)
            }
        }
        
        private var clientIdSection: some View {
            Section(header: Text("Client Id")) {
                TextField("Client ID (Optional)", text: $formData.clientId)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
            }
        }
}

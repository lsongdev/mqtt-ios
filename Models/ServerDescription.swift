import SwiftUI

// MARK: - MQTT Protocol Version
enum MQTTProtocolVersion: Int, Codable, CaseIterable {
    case mqtt3 = 3
    case mqtt5 = 5
    
    var description: String {
        switch self {
        case .mqtt3: return "MQTT 3.1.1"
        case .mqtt5: return "MQTT 5.0"
        }
    }
}

// MARK: - Server Description Model
struct ServerDescription: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String = ""
    var host: String = ""
    var port: String = "1883"
    var clientId: String = ""
    var useTLS: Bool = false
    var username: String = ""
    var password: String = ""
    var protocolVersion: MQTTProtocolVersion = MQTTProtocolVersion.mqtt3
    var subscriptions: [Subscription] = []
    var useWebSocket: Bool = false
    var webSocketPath: String = "/mqtt"
    
    static var empty: ServerDescription {
        let letters = "1234567890abcdefghijklmnopqrstuvwxyz"
        let randomId = String((0..<8).map{ _ in letters.randomElement()! })
        return ServerDescription(
            clientId: "mqtt-\(randomId)"
        )
    }
    var isValid: Bool {
        return !host.isEmpty
    }
    var portN: UInt16 {
        return UInt16(port) ?? (useWebSocket ? (useTLS ? 443 : 80) : 1883)
    }
    var displayName: String {
        return name.isEmpty ? host : name
    }
}

//
//  MQTTClientManager.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI
import CocoaMQTT
import CocoaMQTTWebSocket

class MQTTClient: NSObject, ObservableObject {
    private var client: Any? // Generic type to hold either CocoaMQTT or CocoaMQTT5
    private var currentMessageId: UInt16 = 0
    private let maxMessages: Int = 1000
    @Published var server: ServerDescription
    @Published var messages = CircularBuffer<Message>()
    @Published var connectionState: ConnectionState = .disconnected
    
    enum ConnectionState: Equatable {
        case disconnected
        case connecting
        case connected
        case error(String)
        
        var isConnected: Bool {
            if case .connected = self { return true }
            return false
        }
        
        var canConnect: Bool {
            switch self {
            case .disconnected, .error: return true
            case .connecting, .connected: return false
            }
        }
    }
    
    init(server: ServerDescription){
        self.server = server
    }
    
    func connect() {
        connectionState = .connecting
        switch server.protocolVersion {
        case .mqtt3:
            connectMQTT3(server)
        case .mqtt5:
            connectMQTT5(server)
        }
    }
    
    private func connectMQTT3(_ server: ServerDescription) {
        let socket: CocoaMQTTSocketProtocol = server.useWebSocket ? CocoaMQTTWebSocket(uri: server.webSocketPath) : CocoaMQTTSocket()
        let client = CocoaMQTT(clientID: server.clientId, host: server.host, port: server.portN, socket: socket)
        client.username = server.username
        client.password = server.password
        client.enableSSL = server.useTLS
        // client.allowUntrustCACertificate = true
        client.autoReconnect = true
        client.cleanSession = true
        client.keepAlive = 600 // Increased from 120 to 600 seconds (10 minutes)
        client.delegate = self
    
        if !client.connect() {
            print("MQTT3 连接初始化失败")
            connectionState = .error("Failed to initialize MQTT3 connection")
        }
        self.client = client
    }
    
    private func connectMQTT5(_ server: ServerDescription) {
        let socket: CocoaMQTTSocketProtocol
        if server.useWebSocket {
            socket = CocoaMQTTWebSocket(uri: "/mqtt")
        } else {
            socket = CocoaMQTTSocket()
        }
        let client = CocoaMQTT5(clientID: server.clientId, host: server.host, port: server.portN, socket: socket)
        client.username = server.username
        client.password = server.password
        client.enableSSL = server.useTLS
        client.autoReconnect = true
        client.cleanSession = true
        client.keepAlive = 600 // Increased from 120 to 600 seconds (10 minutes)
//        client.allowUntrustCACertificate = true
//        let connectProperties = MqttConnectProperties()
//        connectProperties.topicAliasMaximum = 0
//        connectProperties.sessionExpiryInterval = 0
//        connectProperties.receiveMaximum = 100
//        connectProperties.maximumPacketSize = 500
//        client.connectProperties = connectProperties
//        client.sslSettings = [kCFStreamSSLPeerName as String: server.host as NSObject]
        
        client.delegate = self
        if !client.connect() {
            print("MQTT5 连接初始化失败")
            connectionState = .error("Failed to initialize MQTT5 connection")
        }
        self.client = client
    }
    
    func disconnect() {
        if let client = client as? CocoaMQTT {
            client.disconnect()
        } else if let client = client as? CocoaMQTT5 {
            client.disconnect()
        }
        client = nil
        connectionState = .disconnected
    }
    
    func publish(to message: Message) {
        // print("publish: \(topic) -> \(payload)")
        let qos = CocoaMQTTQoS(rawValue: UInt8(message.qos)) ?? .qos1
        if let client = client as? CocoaMQTT {
            client.publish(message.topic, withString: message.payload, qos: qos, retained: message.retain)
        } else if let client = client as? CocoaMQTT5 {
            let properties = MqttPublishProperties()
            client.publish(message.topic, withString: message.payload, retained: message.retain, properties: properties)
        }
    }
    
    func subscribe(to topic: String, qos: Int = 0) {
        if let client = client as? CocoaMQTT {
            client.subscribe(topic, qos: CocoaMQTTQoS(rawValue: UInt8(qos)) ?? .qos1)
        } else if let client = client as? CocoaMQTT5 {
            client.subscribe(topic, qos: CocoaMQTTQoS(rawValue: UInt8(qos)) ?? .qos1)
        }
    }
    
    func unsubscribe(from topic: String) {
        if let client = client as? CocoaMQTT {
            client.unsubscribe(topic)
        } else if let client = client as? CocoaMQTT5 {
            client.unsubscribe(topic)
        }
    }
    
    func addMessage(id: UInt16, topic: String, payload: String, qos: Int = 0) {
        currentMessageId = currentMessageId + 1
        messages.append(Message(id: currentMessageId, topic: topic, payload: payload))
        if messages.count > maxMessages {
            messages.removeFirst()
        }
        
        // 发送通知
        if UIApplication.shared.applicationState == .background {
            FlakeAppManager.shared.sendNotification(
                title: topic,
                body: payload
            )
        }
    }
    
    func restoreSubscriptions() {
        for topic in server.subscriptions {
            subscribe(to: topic.name, qos: topic.qos)
        }
    }
}

extension MQTTClient {
    // Validate the server certificate
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        print("mqtt5 certificate verify: \(trust)")
        completionHandler(true)
    }
    // self signed delegate
    func mqttUrlSession(_ mqtt: CocoaMQTT, didReceiveTrust trust: SecTrust, didReceiveChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void){
        print("mqtt3 certificate verify: \(trust)")
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: trust))
            return
        }
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)

    }
}

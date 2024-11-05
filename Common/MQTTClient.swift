//
//  MQTTClientManager.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI
import CocoaMQTT

class MQTTClientManager: NSObject, ObservableObject {
    private var mqttClient: Any? // Generic type to hold either CocoaMQTT or CocoaMQTT5
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
        let client = CocoaMQTT(clientID: server.clientId, host: server.host, port: server.portN)
        
        client.username = server.username
        client.password = server.password
        client.enableSSL = server.useTLS
        client.autoReconnect = true
        client.cleanSession = true
        client.keepAlive = 60
        client.delegate = self
    
        
        if !client.connect() {
            print("MQTT3 连接初始化失败")
            connectionState = .error("Failed to initialize MQTT3 connection")
        }
        
        mqttClient = client
    }
    
    private func connectMQTT5(_ server: ServerDescription) {
        let client = CocoaMQTT5(clientID: server.clientId,
                               host: server.host,
                                port: server.portN)
        
        client.username = server.username
        client.password = server.password
        client.enableSSL = server.useTLS
        client.autoReconnect = true

        client.keepAlive = 60
        client.delegate = self
        
        if !client.connect() {
            print("MQTT5 连接初始化失败")
            connectionState = .error("Failed to initialize MQTT5 connection")
        }
        
        mqttClient = client
    }
    
    func disconnect() {
        if let client = mqttClient as? CocoaMQTT {
            client.disconnect()
        } else if let client = mqttClient as? CocoaMQTT5 {
            client.disconnect()
        }
        mqttClient = nil
        connectionState = .disconnected
    }
    
    func publish(to message: Message) {
//        print("publish: \(topic) -> \(payload)")
        let qos = CocoaMQTTQoS(rawValue: UInt8(message.qos)) ?? .qos1
        if let client = mqttClient as? CocoaMQTT {
            client.publish(message.topic, withString: message.payload, qos: qos, retained: message.retain)
        } else if let client = mqttClient as? CocoaMQTT5 {
            let properties = MqttPublishProperties()
            client.publish(message.topic, withString: message.payload, retained: message.retain, properties: properties)
        }
    }
    
    func subscribe(to topic: String, qos: Int = 0) {
        if let client = mqttClient as? CocoaMQTT {
            client.subscribe(topic, qos: CocoaMQTTQoS(rawValue: UInt8(qos)) ?? .qos1)
        } else if let client = mqttClient as? CocoaMQTT5 {
            client.subscribe(topic, qos: CocoaMQTTQoS(rawValue: UInt8(qos)) ?? .qos1)
        }
    }
    
    func unsubscribe(from topic: String) {
        if let client = mqttClient as? CocoaMQTT {
            client.unsubscribe(topic)
        } else if let client = mqttClient as? CocoaMQTT5 {
            client.unsubscribe(topic)
        }
    }
    
    func addMessage(id: UInt16, topic: String, payload: String, qos: Int = 0) {
        currentMessageId = currentMessageId + 1
        messages.append(Message(id: currentMessageId, topic: topic, payload: payload))
        if messages.count > maxMessages {
            messages.removeFirst()
        }
    }
    func restoreSubscriptions() {
        for topic in server.subscriptions {
            subscribe(to: topic.name, qos: topic.qos)
        }
//        addMessage("Resubscribed to \(server.subscriptions.count) topics")
    }
}


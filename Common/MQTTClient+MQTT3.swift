//
//  Untitled.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI
import CocoaMQTT

// MARK: - CocoaMQTTDelegate
extension MQTTClient: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            connectionState = .connected
            print("Connected to \(mqtt.host)")
            restoreSubscriptions()
        } else {
            connectionState = .error("Connection failed: \(ack)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("MQTT3 消息已发布 - ID: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("MQTT3 消息发布确认 - ID: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("收到 MQTT3 消息 - Topic: \(message.topic), ID: \(id)")
        
        if let text = message.string {
            print("消息内容: \(text)")
            addMessage(id: id, topic: message.topic, payload: text)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("MQTT3 订阅结果 - 成功: \(success), 失败: \(failed)")
        if !failed.isEmpty {
            print("Failed to subscribe to topics: \(failed.joined(separator: ", "))")
        } else {
            print("Successfully subscribed to topics")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("MQTT3 取消订阅主题: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("MQTT3 Ping")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("MQTT3 Pong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: (any Error)?) {
        print("MQTT3 断开连接，错误: \(String(describing: err))")
        DispatchQueue.main.async {
            if let error = err {
                self.connectionState = .error(error.localizedDescription)
            } else {
                self.connectionState = .disconnected
            }
        }
    }
}

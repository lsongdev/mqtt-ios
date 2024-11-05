//
//  MQTTClientManager+MQTT5.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI
import CocoaMQTT

// MARK: - CocoaMQTT5Delegate
extension MQTTClient: CocoaMQTT5Delegate {
    func mqtt5(_ mqtt5: CocoaMQTT5, didConnectAck ack: CocoaMQTTCONNACKReasonCode, connAckData: MqttDecodeConnAck?) {
        if ack == .success {
            connectionState = .connected
            
            // 处理 MQTT5 连接确认数据
            if let connAckData = connAckData {
                print("MQTT5 连接确认数据: \(connAckData)")
            }
            restoreSubscriptions()
        } else {
            connectionState = .error("MQTT5 connection failed: \(ack)")
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishMessage message: CocoaMQTT5Message, id: UInt16) {
        print("MQTT5 消息已发布 - ID: \(id)")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishAck id: UInt16, pubAckData: MqttDecodePubAck?) {
        print("MQTT5 消息发布确认 - ID: \(id)")
        if let pubAckData = pubAckData {
            print("发布确认数据: \(pubAckData)")
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishRec id: UInt16, pubRecData: MqttDecodePubRec?) {
        print("MQTT5 消息发布接收确认 - ID: \(id)")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveMessage message: CocoaMQTT5Message, id: UInt16, publishData: MqttDecodePublish?) {
        print("收到 MQTT5 消息 - Topic: \(message.topic), ID: \(id)")
        
        // 处理 MQTT5 特有的消息属性
        if let publishData = publishData {
            print("消息属性: \(publishData)")
        }
        
        if let text = message.string {
            print("消息内容: \(text)")
            addMessage(id: id, topic: message.topic, payload: text)
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didSubscribeTopics success: NSDictionary, failed: [String], subAckData: MqttDecodeSubAck?) {
        print("MQTT5 订阅结果 - 成功: \(success), 失败: \(failed)")
        if !failed.isEmpty {
//            addMessage("Failed to subscribe to topics: \(failed.joined(separator: ", "))")
        } else {
//            addMessage("Successfully subscribed to topics")
        }
        
        if let subAckData = subAckData {
            print("订阅确认数据: \(subAckData)")
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didUnsubscribeTopics topics: [String], unsubAckData UnsubAckData: MqttDecodeUnsubAck?) {
        print("MQTT5 取消订阅主题: \(topics)")
        if let unsubAckData = UnsubAckData {
            print("取消订阅确认数据: \(unsubAckData)")
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didStateChangeTo state: CocoaMQTTConnState) {
        print("MQTT5 状态改变: \(state)")
        DispatchQueue.main.async {
            switch state {
            case .connecting:
                self.connectionState = .connecting
            case .connected:
                self.connectionState = .connected
            case .disconnected:
                self.connectionState = .disconnected
            default:
                break
            }
        }
    }
    
    func mqtt5DidPing(_ mqtt5: CocoaMQTT5) {
        print("MQTT5 Ping")
    }
    
    func mqtt5DidReceivePong(_ mqtt5: CocoaMQTT5) {
        print("MQTT5 Pong")
    }
    
    func mqtt5DidDisconnect(_ mqtt5: CocoaMQTT5, withError err: Error?) {
        print("MQTT5 断开连接，错误: \(String(describing: err))")
        DispatchQueue.main.async {
            if let error = err {
                self.connectionState = .error(error.localizedDescription)
            } else {
                self.connectionState = .disconnected
            }
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveDisconnectReasonCode reasonCode: CocoaMQTTDISCONNECTReasonCode) {
        print("MQTT5 断开连接原因: \(reasonCode)")
        if reasonCode != .normalDisconnection {
            DispatchQueue.main.async {
                self.connectionState = .error("Disconnected: \(reasonCode)")
            }
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveAuthReasonCode reasonCode: CocoaMQTTAUTHReasonCode) {
        print("MQTT5 认证状态: \(reasonCode)")
    }
    
}

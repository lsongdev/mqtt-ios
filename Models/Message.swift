//
//  Message.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI
import Combine

struct Message: Identifiable, Equatable {
    let id: UInt16
    let timestamp: Date
    var topic: String
    var qos: Int
    var payload: String
    var retain: Bool
    
    init(id: UInt16 = 0, topic: String, payload: String, qos: Int = 0, retain: Bool = false, timestamp: Date = Date()) {
        self.id = id
        self.qos = qos
        self.topic = topic
        self.payload = payload
        self.timestamp = timestamp
        self.retain = retain
    }
    var isValid: Bool {
        return (!topic.isEmpty && !payload.isEmpty)
    }
    static var empty: Message {
        Message(topic: "", payload: "")
    }
}

//
//  Subscription.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//
import SwiftUI

// Make sure TopicItem also conforms to Hashable
struct Subscription: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    var qos: Int
    
    init(id: UUID = UUID(), name: String, qos: Int = 0) {
        self.id = id
        self.name = name
        self.qos = qos
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


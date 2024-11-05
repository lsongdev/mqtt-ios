//
//  CircularBuffer.swift
//  MQTTClient
//
//  Created by Lsong on 1/14/25.
//

struct CircularBuffer<Element> {
    private var array: [Element]
    private var maxSize: Int
    
    init(maxSize: Int = 50) {
        self.maxSize = maxSize
        self.array = []
        self.array.reserveCapacity(maxSize)
    }
    
    mutating func append(_ element: Element) {
        if array.count >= maxSize {
            array.removeFirst()
        }
        array.append(element)
    }
    
    mutating func removeFirst() {
        if !array.isEmpty {
            array.removeFirst()
        }
    }
    
    var count: Int {
        array.count
    }
    
    var last: Element? {
        array.last
    }
    
    subscript(index: Int) -> Element {
        array[index]
    }
    mutating func clear() {
        self.array.removeAll()
    }
}

// MARK: - Protocol Conformances
extension CircularBuffer: RandomAccessCollection {
    typealias Index = Int
    
    var startIndex: Int { array.startIndex }
    var endIndex: Int { array.endIndex }
    
    func index(after i: Int) -> Int {
        array.index(after: i)
    }
    
    func index(before i: Int) -> Int {
        array.index(before: i)
    }
}

extension CircularBuffer: Equatable where Element: Equatable {
    static func == (lhs: CircularBuffer<Element>, rhs: CircularBuffer<Element>) -> Bool {
        lhs.array == rhs.array
    }
}

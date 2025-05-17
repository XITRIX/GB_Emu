//
//  StereoRingBuffer.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 18.05.2025.
//

import Foundation

/// A simple thread-safe ring buffer for (Int16,Int16) pairs.
class StereoRingBuffer {
    private var buffer: [(Int16, Int16)]
    private var head = 0, tail = 0, capacity: Int
    private let lock = DispatchSemaphore(value: 1)

    init(capacity: Int) {
        self.capacity = capacity
        self.buffer = Array(repeating: (0, 0), count: capacity)
    }

    /// Called on emu thread
    func write(_ sample: (Int16, Int16)) {
        lock.wait()
        let next = (head + 1) % capacity
        if next != tail { // if not full
            buffer[head] = sample
            head = next
        }
        lock.signal()
    }

    /// Called on audio thread
    func read() -> (Int16, Int16)? {
        lock.wait()
        defer { lock.signal() }
        if tail == head { return nil } // empty
        let sample = buffer[tail]
        tail = (tail + 1) % capacity
        return sample
    }
}

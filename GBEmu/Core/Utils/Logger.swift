//
//  Logger.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 17.05.2025.
//

import Combine
import Collections

class Logger {
    static let shared = Logger()
    private init() {}

//    @Published var log: String = ""
    @Published var logs = Deque<String>(minimumCapacity: 200)

    static func log(_ message: String, terminator: String = "\n", ignoreXcodeLog: Bool = false) {
        shared.logs.append(message + terminator)
        if shared.logs.count > 199 {
            _ = shared.logs.popFirst()
        }
//        shared.log += message + terminator

        if !ignoreXcodeLog {
            print(message, terminator: terminator)
        }
    }
}

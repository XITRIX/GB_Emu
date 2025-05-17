//
//  APUChannelProtocol.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 17.05.2025.
//

/// 8-step duty wave patterns for the GB square channels
let APUDutyTable: [[UInt8]] = [
    [0, 0, 0, 0, 0, 0, 0, 1], // 12.5%
    [0, 0, 0, 1, 1, 1, 1, 0], // 25%
    [0, 1, 1, 1, 1, 1, 0, 0], // 50%
    [1, 1, 1, 1, 0, 0, 0, 0] // 75%
]

protocol APUChannelProtocol {
    func step(cycles: Int)
    func clockLength()
    func clockEnvelope()
    func clockSweep()
    func currentSample() -> Int16
}

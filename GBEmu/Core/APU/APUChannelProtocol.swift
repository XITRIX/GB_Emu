//
//  APUChannelProtocol.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 17.05.2025.
//

protocol APUChannelProtocol {
    func step(cycles: Int)
    func clockLength()
    func clockEnvelope()
    func clockSweep()
    func currentSample() -> Int16
}

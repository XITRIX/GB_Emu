//
//  Emu.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 12.05.2025.
//

import Foundation

class Emu {
    init(rom: Data) {
        mmu = MMU(rom: [UInt8](rom))
        cpu = CPU(mmu: mmu)
        ppu = PPU(mmu: mmu)

        emulatorLoop = .init(cpu: cpu, ppu: ppu)

        print("Loaded ROM, entry at: \(String(format: "%04X", cpu.PC))")
        print("First 16 bytes at 0x0100:", mmu.rom[0x0100..<0x0110].map { String(format: "%02X", $0) })
    }

    let cpu: CPU
    let mmu: MMU
    let ppu: PPU
    
    private var emulatorLoop: EmulatorLoop!
}

extension Emu {
    func start() {
        emulatorLoop.start()
    }
}

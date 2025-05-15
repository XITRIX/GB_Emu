//
//  Emu.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 12.05.2025.
//

import Foundation

class Emu {
    init(rom: Data, render: @escaping ([UInt32]) -> Void ) {
        mmu = MMU(rom: [UInt8](rom))
        cpu = CPU(mmu: mmu)
        ppu = PPU(mmu: mmu)

        emulatorLoop = .init(cpu: cpu, ppu: ppu, render: render)

//        print("Loaded ROM, entry at: \(String(format: "%04X", cpu.PC))")
//        print("First 16 bytes at 0x0100:", mmu.rom[0x0100..<0x0110].map { String(format: "%02X", $0) })

//        let slice = rom[0x100..<0x110]
//        print("ROM[100..110] =", slice.map { String(format: "%02X", $0) })
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

    func stop() {
        emulatorLoop.stop()
    }

    /// Bits 0–3 reflect the physical button state (0=pressed, 1=released)
    /// Bit 0 = A, 1 = B, 2 = Select, 3 = Start, 4 = Right, 5 = Left, 6 = Up, 7 = Down
    var joypadState: UInt8 {
        get { mmu.joypadState }
        set {
            mmu.joypadState = newValue

            let binary = String(newValue, radix: 2)                   // "1101101"
            let padded = String(repeating: "0", count: 8 - binary.count) + binary
            print("Gamepad: \(padded)")
        }
    }
}

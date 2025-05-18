//
//  Emu.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 12.05.2025.
//

import Foundation

extension Emu {
    struct State: Codable {
        var cpuState: CPU.State
        var mmustate: MMU.State
    }

    func saveState() async {
        stop()
        try? await Task.sleep(nanoseconds: 100)
        let state = State(cpuState: cpu.saveState(), mmustate: mmu.saveState())
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: "\(rom.stableHash)")
        }
        start()
    }

    func loadState() async {
        stop()
        try? await Task.sleep(nanoseconds: 100)
        if let stateData = UserDefaults.standard.object(forKey: "\(rom.stableHash)") as? Data {
            if let state = try? JSONDecoder().decode(State.self, from: stateData) {
                cpu.loadState(state.cpuState)
                mmu.loadState(state.mmustate)
            }
        }
        start()
    }
}

class Emu {
    private(set) var isRunning: Bool = false

    init(rom: Data, render: @escaping ([UInt32]) -> Void) {
        self.rom = rom
        mmu = MMU(rom: [UInt8](rom))
        cpu = CPU(mmu: mmu)
        ppu = PPU(mmu: mmu)
        apu = APU(mmu: mmu)

        emulatorLoop = .init(cpu: cpu, ppu: ppu, apu: apu, render: render)
    }

    let cpu: CPU
    let mmu: MMU
    let ppu: PPU
    let apu: APU

    private let rom: Data
    private var emulatorLoop: EmulatorLoop!
}

extension Emu {
    func start() {
        emulatorLoop.start()
        isRunning = true
    }

    func stop() {
        emulatorLoop.stop()
        isRunning = false
    }

    /// Bits 0–3 reflect the physical button state (0=pressed, 1=released)
    /// Bit 0 = A, 1 = B, 2 = Select, 3 = Start, 4 = Right, 5 = Left, 6 = Up, 7 = Down
    var joypadState: UInt8 {
        get { mmu.joypadState }
        set {
            mmu.joypadState = newValue

            let binary = String(newValue, radix: 2) // "1101101"
            let padded = String(repeating: "0", count: 8 - binary.count) + binary
            Logger.log("Gamepad: \(padded)")
        }
    }
}

private extension Data {
    var stableHash: UInt64 {
        var result = UInt64(5381)
        let buf = [UInt8](self)
        for b in buf {
            result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
        }
        return result
    }
}

//
//  EmulatorLoop.swift
//  Chip8
//
//  Created by Даниил Виноградов on 07.05.2025.
//

import Foundation

class EmulatorLoop {
    private let queue = DispatchQueue(label: "com.gbemu.loop")
    private var running = false
    private var lastTime: DispatchTime = .now()
    private let targetFPS: Double = 60.0
    private let cyclesPerFrame = 70224

    let cpu: CPU
    let ppu: PPU

    init(cpu: CPU, ppu: PPU) {
        self.cpu = cpu
        self.ppu = ppu
    }

    func start() {
        running = true
        lastTime = .now()
        queue.async { self.runLoop() }
    }

    func stop() {
        running = false
    }

    private func runLoop() {
        while running {
            let now = DispatchTime.now()
            let delta = Double(now.uptimeNanoseconds - lastTime.uptimeNanoseconds) / 1_000_000_000
            if delta < (1.0 / targetFPS) {
                let sleepTime = (1.0 / targetFPS) - delta
                usleep(UInt32(sleepTime * 1_000_000))
                continue
            }

            lastTime = now

            // Emulate one frame worth of CPU cycles
            var cycles = 0
            while cycles < cyclesPerFrame {
                let c = cpu.step() // returns cycles used by instruction
                ppu.step(cycles: c)
                // TODO: timers, interrupts
                cycles += c
            }

            // Trigger frame draw (on main thread if using UI)
        }
    }
}

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

    private let render: ([UInt32]) -> Void

    let cpu: CPU
    let ppu: PPU

    init(cpu: CPU, ppu: PPU, render: @escaping ([UInt32]) -> Void) {
        self.cpu = cpu
        self.ppu = ppu
        self.render = render
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
            // 1) Frame pacing
            let now = DispatchTime.now()
            let delta = Double(now.uptimeNanoseconds - lastTime.uptimeNanoseconds) / 1_000_000_000
            if delta < (1.0 / targetFPS) {
                let sleepTime = (1.0 / targetFPS) - delta
                usleep(UInt32(sleepTime * 1_000_000))
                continue
            }

            lastTime = now

            // 2) Run one frame’s worth of cycles
            var cycles = 0
            while cycles < cyclesPerFrame {
                if cpu.stopped { break }

                let used = cpu.step() // returns cycles used by instruction
                ppu.step(cycles: used)
                // TODO: timers, interrupts
                cycles += used
            }

            // 3) Handle STOP state: completely suspend emulation
            if !cpu.checkStopState() {
                continue
            }

            // 4) Render the framebuffer (on main thread if needed)
            DispatchQueue.main.async { [self] in render(ppu.framebuffer) }
        }
    }
}

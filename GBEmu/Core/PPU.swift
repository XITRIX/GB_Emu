//
//  PPU.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 12.05.2025.
//

class PPU {
    var vram: [UInt8] { mmu.vram }      // Linked to MMU
    var oam: [UInt8] = []               // Sprite data
    var framebuffer: [UInt32] = Array(repeating: 0, count: 160 * 144)
    let mmu: MMU

    init(mmu: MMU) {
        self.mmu = mmu
    }

    var currentScanline: Int = 0
    var mode: Int = 0

    func step(cycles: Int) {
        // TODO: Track cycles, switch modes, draw scanlines
    }

    func drawScanline() {
        // Fetch background tile data, scroll X/Y, palettes, etc.
        // Draw 160 pixels to framebuffer for currentScanline
    }
}

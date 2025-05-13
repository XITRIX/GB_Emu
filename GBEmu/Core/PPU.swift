//
//  PPU.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 12.05.2025.
//

class PPU {
    var vram: [UInt8] { mmu.vram } // Linked to MMU
    var oam: [UInt8] = [] // Sprite data
    var framebuffer: [UInt32] = Array(repeating: 0, count: 160 * 144)
    let mmu: MMU

    init(mmu: MMU) {
        self.mmu = mmu
    }

    var mode: Int = 0
    var currentScanline: UInt8 {
        get { mmu.read(0xFF44) }
        set { mmu.write(newValue, to: 0xFF44) }
    }

    func step(cycles: Int) {
        mode += cycles
        // Each scanline = 456 T-cycles
        while mode >= 456 {
            mode -= 456
            currentScanline = currentScanline &+ 1
            if currentScanline == 144 {
                // VBlank interrupt, etc.
            } else if currentScanline > 153 {
                currentScanline = 0
            }
        }
    }

    func drawScanline() {
        // Fetch background tile data, scroll X/Y, palettes, etc.
        // Draw 160 pixels to framebuffer for currentScanline
    }
}

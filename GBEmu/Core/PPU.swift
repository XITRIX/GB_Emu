//
//  PPU.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 12.05.2025.
//

extension PPU {
    enum Mode: Int {
        case oamSearch = 2, pixelTransfer = 3, hblank = 0, vblank = 1
    }
}

class PPU {
    var vram: [UInt8] { mmu.vram } // Linked to MMU
    var oam: [UInt8] {
        get { mmu.oam }
        set { mmu.oam = newValue }
    }

    var framebuffer: [UInt32] = Array(repeating: 0, count: 160 * 144)

    init(mmu: MMU) {
        self.mmu = mmu
    }

    private let mmu: MMU
    private var modeClock = 0
    private var _mode: Mode = .oamSearch
}

extension PPU {
    var mode: Mode {
        get { _mode }
        set {
            _mode = newValue
            // on entering pixelTransfer, render the scanline:
            if newValue == .pixelTransfer {
                drawScanline()
            }
            // on entering vblank, fire the interrupt
            if newValue == .vblank {
                mmu.requestInterrupt(.vblank)
            }
        }
    }

    var currentScanline: UInt8 {
        get { mmu.read(0xff44) }
        set { mmu.write(newValue, to: 0xff44) }
    }

    func step(cycles: Int) {
        modeClock += cycles

        switch mode {
        case .oamSearch:
            if modeClock >= 80 {
                modeClock -= 80
                mode = .pixelTransfer
            }
        case .pixelTransfer:
            if modeClock >= 172 { // often ~172, you can use 172 or 204 for safety
                modeClock -= 172
                mode = .hblank
            }
        case .hblank:
            if modeClock >= (456 - 80 - 172) {
                modeClock -= (456 - 80 - 172)
                currentScanline &+= 1
                if currentScanline == 144 {
                    mode = .vblank
                } else {
                    mode = .oamSearch
                }
            }
        case .vblank:
            if modeClock >= 456 {
                modeClock -= 456
                currentScanline &+= 1
                if currentScanline > 153 {
                    currentScanline = 0
                    mode = .oamSearch
                }
            }
        }
    }

    func drawScanline() {
        let ly = Int(currentScanline)

        // 1) Background/Window
        for x in 0..<160 {
            let bgColor = fetchBgPixel(x: x, y: ly)
            let bgPalette = mmu.read(0xFF47)
            framebuffer[ly * 160 + x] = paletteToARGB(bgColor, isSprite: false, paletteIndex: bgPalette)
        }

        // 2) Sprites
        let spriteHeight = (mmu.read(0xff40) & 0x04) != 0 ? 16 : 8
        var spritesOnLine: [(index: Int, x: Int)] = []
        for i in 0..<40 {
            let oamy = Int(oam[i * 4 + 0]) - 16
            let oamx = Int(oam[i * 4 + 1]) - 8
            if ly >= oamy, ly < oamy + spriteHeight {
                spritesOnLine.append((i, oamx))
                if spritesOnLine.count == 10 { break }
            }
        }

        // in hardware order: lowest OAM index first
        for (i, spriteX) in spritesOnLine {
            let spriteY = Int(oam[i * 4 + 0]) - 16
            let tileIndex = UInt8(oam[i * 4 + 2])
            let attrs = oam[i * 4 + 3]
            let lineInSprite = (ly - spriteY) ^ ((attrs & 0x40) != 0 ? (spriteHeight - 1) : 0)
            let (lo, hi) = readSpriteTileBytes(tileIndex: tileIndex, line: lineInSprite)
            for pixel in 0..<8 {
                let bit = (attrs & 0x20) != 0 ? pixel : (7 - pixel)
                let colorNum = ((hi >> bit) & 1) << 1 | ((lo >> bit) & 1)
                if colorNum == 0 { continue } // transparent
                let palette = (attrs & 0x10) != 0 ? mmu.read(0xff49) : mmu.read(0xff48)
                let argb = paletteToARGB(colorNum, isSprite: true, paletteIndex: palette)
                let fbX = spriteX + pixel
                if fbX >= 0, fbX < 160 {
                    // optionally handle sprite priority over BG
                    framebuffer[ly * 160 + fbX] = argb
                }
            }
        }
    }
}

private extension PPU {
    /// Reads the background (or window) tilemap + tile data and returns the 0–3 colour number
    /// at screen-pixel (x, y). Respects SCX/SCY, LCDC.BG enable, tile‐map and tile‐data select.
    func fetchBgPixel(x: Int, y: Int) -> UInt8 {
      let lcdc = mmu.read(0xff40)
      guard (lcdc & 0x01) != 0 else { return 0 }

      let scy = mmu.read(0xff42)
      let scx = mmu.read(0xff43)
      let bgY = UInt16(y) &+ UInt16(scy)
      let bgX = UInt16(x) &+ UInt16(scx)

      let tileMapBase: UInt16 = (lcdc & 0x08) != 0 ? 0x9c00 : 0x9800
      let useUnsigned = (lcdc & 0x10) != 0
      let tileDataBase: UInt16 = useUnsigned ? 0x8000 : 0x9000

      // figure out which tile in the map
      let mapRow = Int(bgY / 8) * 32
      let mapCol = Int(bgX / 8)
      let rawIndex = mmu.read(tileMapBase + UInt16(mapRow + mapCol))

      // signed vs unsigned tile number
      let tileNumber = useUnsigned
        ? Int(rawIndex)
        : Int(Int8(bitPattern: rawIndex))

      // which two bytes in that tile for this scanline?
      let lineInTile = Int(bgY % 8) * 2

      // do all of this in Int, so that tileNumber * 16 can be negative
      let signedAddr = Int(tileDataBase) + (tileNumber * 16) + lineInTile
      let lo = mmu.read(UInt16(signedAddr))
      let hi = mmu.read(UInt16(signedAddr + 1))

      let bit = 7 - Int(bgX % 8)
      let colorNum = UInt8(((hi >> bit) & 1) << 1 | ((lo >> bit) & 1))
      return colorNum
    }

    /// Turns a colour number (0–3) plus a BGP/OBP0/OBP1 palette byte into a 32-bit ARGB shade.
    /// If you skip sprite-pixelNum==0 in your drawScanline, you don’t need to handle transparency here.
    func paletteToARGB(
        _ colorNum: UInt8,
        isSprite: Bool,
        paletteIndex: UInt8
    ) -> UInt32 {
        // Extract the two bits for this colourNum from the palette register:
        //    bit 0 → paletteIndex >> (2*colourNum)
        //    bit 1 → paletteIndex >> (2*colourNum + 1)
        let lo = (paletteIndex >> (2 * colorNum)) & 0x01
        let hi = (paletteIndex >> (2 * colorNum + 1)) & 0x01
        let shade = (hi << 1) | lo // 0..3

        // Map Game Boy shades to ARGB. 0 is white, 3 is black.
        switch shade {
        case 0: return 0xffffffff // white
        case 1: return 0xffaaaaaa // light gray
        case 2: return 0xff555555 // dark gray
        case 3: return 0xff000000 // black
        default: return 0xffffffff
        }
    }

    /// Sprite height in pixels (8 or 16), from LCDC bit 2
    var spriteHeight: Int {
        let lcdc = mmu.read(0xff40)
        return (lcdc & 0x04) != 0 ? 16 : 8
    }

    /// Read a single 8×8 tile’s two bit‐planes for the given row (0–7)
    func readTileBytes(tileIndex: UInt8, line: Int) -> (UInt8, UInt8) {
        let base: UInt16 = 0x8000
        let tile = UInt16(tileIndex)
        let rowOff = UInt16(line & 0x7) * 2
        let addr = base + tile * 16 + rowOff
        return (mmu.read(addr), mmu.read(addr + 1))
    }

    /// Top‐level sprite fetch that handles 8×8 *and* 8×16
    func readSpriteTileBytes(tileIndex: UInt8, line: Int) -> (UInt8, UInt8) {
        let h = spriteHeight
        if h == 8 {
            // simple 8×8
            return readTileBytes(tileIndex: tileIndex, line: line)
        } else {
            // 8×16 mode: ignore the low bit of the tile index,
            // then pick tile 0 for lines 0–7, tile 1 for 8–15
            let baseTile = tileIndex & 0xfe
            let whichTile = baseTile + UInt8(line / 8) // 0 or +1
            let rowInTile = line % 8
            return readTileBytes(tileIndex: whichTile, line: rowInTile)
        }
    }
}

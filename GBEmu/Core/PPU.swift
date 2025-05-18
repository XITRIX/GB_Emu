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
            updateSTAT(mode: newValue)
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
                checkLYC()
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
                checkLYC()
                if currentScanline > 153 {
                    currentScanline = 0
                    mode = .oamSearch
                }
            }
        }
    }

    func drawScanline() {
        let ly = Int(currentScanline)
        let lcdc = mmu.read(0xff40)

        // LCDC flags
        let bgEnable = (lcdc & 0x01) != 0
        let objEnable = (lcdc & 0x02) != 0
        let objHeight = (lcdc & 0x04) != 0 ? 16 : 8
        let bgTileMap = (lcdc & 0x08) != 0 ? 0x9c00 : 0x9800
        let tileDataBase = (lcdc & 0x10) != 0 ? 0x8000 : 0x9000
        let winEnable = (lcdc & 0x20) != 0
        let winTileMap = (lcdc & 0x40) != 0 ? 0x9c00 : 0x9800

        // Scroll + window pos
        let scy = Int(mmu.read(0xff42))
        let scx = Int(mmu.read(0xff43))
        let wy = Int(mmu.read(0xff4a))
        let wx = Int(mmu.read(0xff4b)) - 7 // window X is offset by 7

        // palettes
        let bgPalette = mmu.read(0xff47)
        let obp0 = mmu.read(0xff48)
        let obp1 = mmu.read(0xff49)

        // 1) First pass: BG + Window → we store raw color‐nums so sprites can test priority
        var bgLine = [UInt8](repeating: 0, count: 160)
        for x in 0..<160 {
            var colorNum: UInt8 = 0

            // Window has priority over BG when enabled
            if winEnable, ly >= wy, x >= wx {
                let wxp = x - wx
                let wyp = ly - wy

                // which tile?
                let tileX = wxp / 8
                let tileY = wyp / 8
                let mapAddr = UInt16(winTileMap) + UInt16(tileY * 32 + tileX)
                let rawIdx = mmu.read(mapAddr)
                let useUnsigned = (lcdc & 0x10) != 0
                let tileNum: Int = useUnsigned
                    ? Int(rawIdx)
                    : Int(Int8(bitPattern: rawIdx)) // signed indexing

                // which line in that tile?
                let lineInTile = (wyp % 8) * 2
                let signedAddr = tileDataBase + tileNum * 16 + lineInTile
                let tileAddr = UInt16(signedAddr)        // now always non‐negative
                let lo = mmu.read(tileAddr)
                let hi = mmu.read(tileAddr + 1)
                let bit = 7 - (wxp % 8)
                colorNum = ((hi >> bit) & 1) << 1 | ((lo >> bit) & 1)

            } else if bgEnable {
                // background
                let bxp = (x + scx) & 0xFF
                let byp = (ly + scy) & 0xFF

                let tileX = bxp / 8
                let tileY = byp / 8
                let mapAddr = UInt16(bgTileMap) + UInt16(tileY * 32 + tileX)
                let rawIdx  = mmu.read(mapAddr)

                // signed vs unsigned tile number
                let useUnsigned = (lcdc & 0x10) != 0
                let tileNum: Int = useUnsigned
                    ? Int(rawIdx)
                    : Int(Int8(bitPattern: rawIdx))

                // which two bytes in that tile for this scanline?
                let lineInTile = (byp % 8) * 2

                // compute full address as an Int, then cast once
                let signedAddr = tileDataBase + tileNum * 16 + lineInTile
                let tileAddr = UInt16(signedAddr)        // now always non‐negative
                let lo = mmu.read(tileAddr)
                let hi = mmu.read(tileAddr + 1)

                let bit = 7 - (bxp % 8)
                colorNum = UInt8(((hi >> bit) & 1) << 1 | ((lo >> bit) & 1))
            }

            bgLine[x] = colorNum
            framebuffer[ly * 160 + x] = paletteToARGB(colorNum,
                                                      isSprite: false,
                                                      paletteIndex: bgPalette)
        }

        // 2) Sprite pass
        guard objEnable else { return }
        // collect up to 10 sprites on this line, in OAM order
        var spritesOnLine: [(idx: Int, x: Int, y: Int, tile: UInt8, attrs: UInt8)] = []
        for i in 0..<40 {
            let sy = Int(oam[i * 4 + 0]) - 16
            let sx = Int(oam[i * 4 + 1]) - 8
            if ly >= sy, ly < sy + objHeight {
                spritesOnLine.append((i, sx, sy,
                                      oam[i * 4 + 2],
                                      oam[i * 4 + 3]))
                if spritesOnLine.count == 10 { break }
            }
        }

        for sprite in spritesOnLine {
            let (i, sx, sy, tileIndex, attrs) = sprite

            // vertical flip?
            let lineInSprite = ly - sy
            let row = (attrs & 0x40) != 0
                ? objHeight - 1 - lineInSprite
                : lineInSprite

            // fetch sprite tile bytes (handles 8×16 when objHeight==16)
            let (lo, hi) = readSpriteTileBytes(tileIndex: tileIndex,
                                               line: row)

            for px in 0..<8 {
                let bitIndex = (attrs & 0x20) != 0
                    ? px // X-flip
                    : (7 - px)
                let colorNum = ((hi >> bitIndex) & 1) << 1
                    | ((lo >> bitIndex) & 1)
                guard colorNum != 0 else { continue } // transparent

                let paletteIndex = (attrs & 0x10) != 0 ? obp1 : obp0
                let argb = paletteToARGB(colorNum,
                                         isSprite: true,
                                         paletteIndex: paletteIndex)

                let fbX = sx + px
                guard fbX >= 0, fbX < 160 else { continue }

                // priority: if bit7 of attrs is set, sprite is “behind” non-zero BG
                if (attrs & 0x80) != 0, bgLine[fbX] != 0 {
                    continue
                }

                framebuffer[ly * 160 + fbX] = argb
            }
        }
    }
}

private extension PPU {
    func updateSTAT(mode newMode: Mode) {
        // read-only upper bits [7:3] are the STAT-interrupt enables
        var stat = mmu.read(0xff41) & 0xf8
        // bits 1–0 = newMode
        stat |= UInt8(newMode.rawValue)
        mmu.write(stat, to: 0xff41)
    }

    func checkLYC() {
        let ly = mmu.read(0xff44)
        let lyc = mmu.read(0xff45)
        var stat = mmu.read(0xff41)
        let coincided = (ly == lyc)
        // bit 2 = coincidence flag
        if coincided {
            stat |= 0x04
            // if LYC interrupt enabled (STAT bit 6), fire it:
            if (stat & 0x40) != 0 { mmu.requestInterrupt(.lcdStat) }
        } else {
            stat &= ~UInt8(0x04)
        }
        mmu.write(stat, to: 0xff41)
    }

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

//
//  MMU.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 12.05.2025.
//

class MMU {
    var rom: [UInt8]
    var ram: [UInt8] = Array(repeating: 0, count: 0x2000)
    var vram: [UInt8] = Array(repeating: 0, count: 0x2000)
    var wram: [UInt8] = Array(repeating: 0, count: 0x2000)
    var oam: [UInt8]  = Array(repeating: 0, count: 0xA0)
    var hram: [UInt8] = Array(repeating: 0, count: 0x7F)
    var io: [UInt8]   = Array(repeating: 0, count: 0x80)
    var interruptEnable: UInt8 = 0

    init(rom: [UInt8]) {
        self.rom = rom
    }

    func read(_ address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x7FFF: return rom[Int(address)]
        case 0x8000...0x9FFF: return vram[Int(address - 0x8000)]
        case 0xA000...0xBFFF: return ram[Int(address - 0xA000)]
        case 0xC000...0xDFFF: return wram[Int(address - 0xC000)]
        case 0xE000...0xFDFF: return wram[Int(address - 0xE000)] // echo
        case 0xFE00...0xFE9F: return oam[Int(address - 0xFE00)]
        case 0xFF00...0xFF7F: return io[Int(address - 0xFF00)]
        case 0xFF80...0xFFFE: return hram[Int(address - 0xFF80)]
        case 0xFFFF: return interruptEnable
        default: return 0xFF
        }
    }

    func write(_ value: UInt8, to address: UInt16) {
        switch address {
        case 0x8000...0x9FFF: vram[Int(address - 0x8000)] = value
        case 0xA000...0xBFFF: ram[Int(address - 0xA000)] = value
        case 0xC000...0xDFFF: wram[Int(address - 0xC000)] = value
        case 0xE000...0xFDFF: wram[Int(address - 0xE000)] = value
        case 0xFE00...0xFE9F: oam[Int(address - 0xFE00)] = value
        case 0xFF00...0xFF7F:
            io[Int(address - 0xFF00)] = value
            if address == 0xFF02 {
                let char = Character(UnicodeScalar(value))
                print(char, terminator: "")
            }
            if address == 0xFF02, (value & 0x80) != 0 {
                // Serial transfer requested:
                let byte = io[0x01]
                let char = Character(UnicodeScalar(byte))
                print(char, terminator: "")
            }
        case 0xFF80...0xFFFE: hram[Int(address - 0xFF80)] = value
        case 0xFFFF: interruptEnable = value
        default: break
        }
    }
}

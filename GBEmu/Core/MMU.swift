//
//  MMU.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 12.05.2025.
//

import Foundation

enum Interrupt: UInt8 {
    /// V-Blank (bit 0)
    case vblank   = 0
    /// LCD STAT  (bit 1)
    case lcdStat  = 1
    /// Timer     (bit 2)
    case timer    = 2
    /// Serial    (bit 3)
    case serial   = 3
    /// Joypad    (bit 4)
    case joypad   = 4

    /// The mask to set/test this interrupt in IF/IE
    var mask: UInt8 { 1 << rawValue }
}

class MMU {
    private let memoryBankController: MBC
    var vram: [UInt8] = Array(repeating: 0, count: 0x2000)
    private var wram: [UInt8] = Array(repeating: 0, count: 0x2000)
    var oam: [UInt8] = Array(repeating: 0, count: 0xA0)
    private var hram: [UInt8] = Array(repeating: 0, count: 0x7F)
    private var io: [UInt8] = Array(repeating: 0, count: 0x80)
    private var interruptEnable: UInt8 = 0

    private var localJoypadState: UInt8 = 0xFF
    private let inputQueue = DispatchQueue(label: "com.gbemu.input")

    private let interruptFlagAddr: UInt16 = 0xFF0F

    /// Bits 0–3 reflect the physical button state (0=pressed, 1=released)
    /// Bit 0 = A, 1 = B, 2 = Select, 3 = Start, 4 = Right, 5 = Left, 6 = Up, 7 = Down
    var joypadState: UInt8 {
        get { inputQueue.sync { localJoypadState } }
        set { inputQueue.sync { localJoypadState = newValue } }
    }

    init(rom: [UInt8]) {
        memoryBankController = .init(rom: rom)
    }

    subscript(address: UInt16) -> UInt8 {
        get { read(address) }
        set { write(newValue, to: address) }
    }

    func read(_ address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x7FFF, 0xA000...0xBFFF:
            return memoryBankController.read(address)    // External RAM
            
        case 0x8000...0x9FFF: return vram[Int(address - 0x8000)]
        case 0xC000...0xDFFF: return wram[Int(address - 0xC000)]
        case 0xE000...0xFDFF: return wram[Int(address - 0xE000)] // echo
        case 0xFE00...0xFE9F: return oam[Int(address - 0xFE00)]
        case 0xFF00...0xFF7F:
            if address == 0xFF00 {
                let select = io[0x00] & 0x30
                // bits 0–3 of `joypadState` are the real button bits (0=down)
                let buttons = joypadState & 0x0F
                // bits 4–7 of `joypadState` are directional bits (0=down)
                let dirs = (joypadState >> 4) & 0x0F

                // if P15=0 (bit5=0) we return button bits; else high
                // if P14=0 (bit4=0) we return dir bits
                let lower = ((select & 0x20) == 0 ? buttons : 0x0F)
                    & ((select & 0x10) == 0 ? dirs : 0x0F)

                return select | lower
            } else {
                return io[Int(address - 0xFF00)]
            }
        case 0xFF80...0xFFFE: return hram[Int(address - 0xFF80)]
        case 0xFFFF: return interruptEnable
        default: return 0xFF
        }
    }

    func write(_ value: UInt8, to address: UInt16) {
        switch address {
        // ROM adresses
        case 0x0000...0x7FFF, 0xA000...0xBFFF:
            memoryBankController.write(value, to: address)

        // Internal RAM adresses
        case 0xC000...0xDFFF: wram[Int(address - 0xC000)] = value
        case 0x8000...0x9FFF: vram[Int(address - 0x8000)] = value
        case 0xE000...0xFDFF: wram[Int(address - 0xE000)] = value
        case 0xFE00...0xFE9F: oam[Int(address - 0xFE00)] = value
        case 0xFF00...0xFF7F:
            io[Int(address - 0xFF00)] = value
//            print(String(format: "IO-WRITE @%04X ← %02X", address, value))

            if address == 0xFF00 {
                // CPU is selecting which half of the pad it wants to read:
                //   bit5 (P15)=0 → buttons (A,B,Select,Start)
                //   bit4 (P14)=0 → directions (Right,Left,Up,Down)
                // we store that in io[0x00]
                io[0x00] = (value & 0x30) | 0x0F // preserve only bits 4–5, lower 4 bits forced high
            }

            // Serial port
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

    func requestInterrupt(_ interrupt: Interrupt) {
        let currentFlags = read(interruptFlagAddr)
        write(currentFlags | interrupt.mask, to: interruptFlagAddr)
    }
}

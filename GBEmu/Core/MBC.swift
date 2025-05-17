//
//  MBC.swift
//  GBEmu
//
//  Created by Daniil Vinogradov on 14/05/2025.
//

class MBC {
    init(rom: [UInt8]) {
        self.rom = rom
    }

    private var rom: [UInt8]

    // TODO: init real amount of banks reading ROM header
    private var extRamBanks: [[UInt8]] = Array(repeating: Array(repeating: 0, count: 0x2000), count: 10)

    // MBC1 state
    private var romBankLow5: UInt8 = 1 // bits 0–4
    private var romBankHigh2: UInt8 = 0 // bits 5–6
    private var bankingMode: UInt8 = 0 // 0 = ROM, 1 = RAM
    private var ramEnabled = false
}

extension MBC {
    func read(_ address: UInt16) -> UInt8 {
        switch address {
        // --- Fixed bank 0 ---
        case 0x0000...0x3FFF:
            return rom[Int(address)]

        // --- Switchable bank ---
        case 0x4000...0x7FFF:
            let bankNum = currentRomBank
            let offset = bankNum * 0x4000 + (Int(address) - 0x4000)
            
            guard offset < rom.count else { return 0xFF }
            return rom[offset]

        // --- RAM access ---
        case 0xA000...0xBFFF:
            guard ramEnabled else { return 0xFF }
            let bank = currentRamBank
            let idx  = Int(address - 0xA000)
            return extRamBanks[bank][idx]

        // --- NOT RAM/ROM ADDRESS ---
        default:
            Logger.log("Reading from address \(String(format: "%04x", address)) is not allowed, valid range is 0x0000...0x7FFF")
            return 0xFF
        }
    }

    func write(_ value: UInt8, to address: UInt16) {
        switch address {
        case 0x0000...0x1FFF:
            ramEnabled = (value & 0x0F) == 0x0A

        // --- ROM-bank low bits (0x2000–0x3FFF) ---
        case 0x2000...0x3FFF:
            // mask to 5 bits
            romBankLow5 = value & 0x1f
            if romBankLow5 == 0 { romBankLow5 = 1 } // no bank 0

        // --- ROM-bank high bits or RAM mode (0x4000–0x5FFF) ---
        case 0x4000...0x5FFF:
            romBankHigh2 = value & 0x03

        // --- Banking mode select (0x6000–0x7FFF) ---
        case 0x6000...0x7FFF:
            bankingMode = value & 0x01

        // --- RAM access ---
        case 0xA000...0xBFFF:
            guard ramEnabled else { return }
            let bank = currentRamBank
            let idx  = Int(address - 0xA000)
            extRamBanks[bank][idx]
            extRamBanks[bank][idx] = value

        // --- NOT RAM/ROM ADDRESS ---
        default:
            Logger.log("Writing to address \(String(format: "%04x", address)) is not allowed")
        }
    }
}

private extension MBC {
    var currentRomBank: Int {
        let low = Int(romBankLow5)
        let high = (bankingMode == 0 ? Int(romBankHigh2) : 0) << 5
        let n = (high | low) & 0x7F
        return n == 0 ? 1 : n
    }

    var currentRamBank: Int {
      return bankingMode == 1 ? Int(romBankHigh2 & 0x03) : 0
    }
}

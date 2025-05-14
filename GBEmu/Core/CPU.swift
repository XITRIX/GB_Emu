//
//  CPU.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 12.05.2025.
//

import Foundation

enum Register: Int {
    case A, F, B, C, D, E, H, L
//    case SP, PC
}

enum Opcode: UInt8 {
    case nop = 0x00
    case ldBB = 0x40
    case ldBC = 0x41
    case ldBD = 0x42
    case ldBE = 0x43
    case ldBH = 0x44
    case ldBL = 0x45
    case ldBA = 0x47
    case ldCB = 0x48
    case ldCC = 0x49
    case ldCD = 0x4A
    case ldCE = 0x4B
    case ldCH = 0x4C
    case ldCL = 0x4D
    case ldCA = 0x4F
    case ldDB = 0x50
    case ldDC = 0x51
    case ldDD = 0x52
    case ldDE = 0x53
    case ldDH = 0x54
    case ldDL = 0x55
    case ldDA = 0x57
    case ldEB = 0x58
    case ldEC = 0x59
    case ldED = 0x5A
    case ldEE = 0x5B
    case ldEH = 0x5C
    case ldEL = 0x5D
    case ldEA = 0x5F
    case ldHB = 0x60
    case ldHC = 0x61
    case ldHD = 0x62
    case ldHE = 0x63
    case ldHH = 0x64
    case ldHL = 0x65
    case ldHA = 0x67
    case ldLB = 0x68
    case ldLC = 0x69
    case ldLD = 0x6A
    case ldLE = 0x6B
    case ldLH = 0x6C
    case ldLL = 0x6D
    case ldLA = 0x6F
    case ldAB = 0x78
    case ldAC = 0x79
    case ldAD = 0x7A
    case ldAE = 0x7B
    case ldAH = 0x7C
    case ldAL = 0x7D
    case ldAA = 0x7F
    case ldA_a8 = 0xF0
    case ldB_d8 = 0x06
    case ldD_d8 = 0x16
    case ldH_d8 = 0x26
    case ldC_d8 = 0x0E
    case ldE_d8 = 0x1E
    case ldL_d8 = 0x2E
    case ldA_d8 = 0x3E
    case ldA_a16 = 0xFA
    case ld_a8_A = 0xE0
    case ld_a16_A = 0xEA
    case ldC_A = 0xE2
    case ldA_C = 0xF2
    case ldHL_d8 = 0x36
    case ldHL_B = 0x70
    case ldHL_C = 0x71
    case ldHL_D = 0x72
    case ldHL_E = 0x73
    case ldHL_H = 0x74
    case ldHL_L = 0x75
    case ldHL_A = 0x77
    case ldBC_A = 0x02
    case ldDE_A = 0x12
    case ldHL_inc_A = 0x22
    case ldHL_dec_A = 0x32
    case ldBC_d16 = 0x01
    case ldDE_d16 = 0x11
    case ldHL_d16 = 0x21
    case ldSP_d16 = 0x31
    case ldA_BC = 0x0A
    case ldA_DE = 0x1A
    case ldA_HL_inc = 0x2A
    case ldA_HL_dec = 0x3A
    case ldB_HL = 0x46
    case ldD_HL = 0x56
    case ldH_HL = 0x66
    case ldC_HL = 0x4E
    case ldE_HL = 0x5E
    case ldL_HL = 0x6E
    case ldA_HL = 0x7E
    case ldSP_HL = 0xF9
    case jp_a16 = 0xC3
    case jr_s8 = 0x18
    case jrNZ_r8 = 0x20
    case jrNC_r8 = 0x30
    case jrZ_r8 = 0x28
    case jrC_r8 = 0x38
    case addAB = 0x80
    case addAC = 0x81
    case addAD = 0x82
    case addAE = 0x83
    case addAH = 0x84
    case addAL = 0x85
    case addA_HL = 0x86
    case addAA = 0x87
    case addA_d8 = 0xC6
    case sub_d8 = 0xD6
    case xorB = 0xA8
    case xorC = 0xA9
    case xorD = 0xAA
    case xorE = 0xAB
    case xorH = 0xAC
    case xorL = 0xAD
    case xor_HL = 0xAE
    case xorA = 0xAF
    case xorA_d8 = 0xEE
    case orB = 0xB0
    case orC = 0xB1
    case orD = 0xB2
    case orE = 0xB3
    case orH = 0xB4
    case orL = 0xB5
    case orA = 0xB7
    case and_d8 = 0xE6
    case call_a16 = 0xCD
    case callNZ_a16 = 0xC4
    case retNZ = 0xC0
    case retZ = 0xC8
    case retNC = 0xD0
    case retC = 0xD8
    case ret = 0xC9
    case retI = 0xD9
    case pushBC = 0xC5
    case pushDE = 0xD5
    case pushHL = 0xE5
    case pushAF = 0xF5
    case popBC = 0xC1
    case popDE = 0xD1
    case popHL = 0xE1
    case popAF = 0xF1
    case incB = 0x04
    case incD = 0x14
    case incH = 0x24
    case incC = 0x0C
    case incE = 0x1C
    case incL = 0x2C
    case incA = 0x3C
    case decB = 0x05
    case decD = 0x15
    case decH = 0x25
    case decC = 0x0D
    case decE = 0x1D
    case decL = 0x2D
    case decA = 0x3D
    case incBC = 0x03
    case incDE = 0x13
    case incHL = 0x23
    case incSP = 0x33
    case cp_d8 = 0xFE
    case rra = 0x1F
    case di = 0xF3
    case ei = 0xFB
    case stop = 0x10
    case cb = 0xCB
}

enum CBOpcode: UInt8 {
    case rlcB = 0x00
    case rrB = 0x18
    case rrC = 0x19
    case rrD = 0x1A
    case rrE = 0x1B
    case rrH = 0x1C
    case rrL = 0x1D
    case rrA = 0x1F
    case slaB = 0x20
    case slaC = 0x21
    case slaD = 0x22
    case slaE = 0x23
    case slaH = 0x24
    case slaL = 0x25
    case slaA = 0x27
    case srlB = 0x38
    case bit0B = 0x40
    case bit0C = 0x41
    case bit0D = 0x42
    case bit0E = 0x43
    case bit0H = 0x44
    case bit0L = 0x45
    case bit0_HL = 0x46
    case bit0A = 0x47
    case bit1B = 0x48
    case bit1C = 0x49
    case bit1D = 0x4A
    case bit1E = 0x4B
    case bit1H = 0x4C
    case bit1L = 0x4D
    case bit1_HL = 0x4E
    case bit1A = 0x4F
    case bit2B = 0x50
    case bit2C = 0x51
    case bit2D = 0x52
    case bit2E = 0x53
    case bit2H = 0x54
    case bit2L = 0x55
    case bit2_HL = 0x56
    case bit2A = 0x57
    case bit3B = 0x58
    case bit3C = 0x59
    case bit3D = 0x5A
    case bit3E = 0x5B
    case bit3H = 0x5C
    case bit3L = 0x5D
    case bit3_HL = 0x5E
    case bit3A = 0x5F
    case bit4B = 0x60
    case bit4C = 0x61
    case bit4D = 0x62
    case bit4E = 0x63
    case bit4H = 0x64
    case bit4L = 0x65
    case bit4_HL = 0x66
    case bit4A = 0x67
    case bit5B = 0x68
    case bit5C = 0x69
    case bit5D = 0x6A
    case bit5E = 0x6B
    case bit5H = 0x6C
    case bit5L = 0x6D
    case bit5_HL = 0x6E
    case bit5A = 0x6F
    case bit6B = 0x70
    case bit6C = 0x71
    case bit6D = 0x72
    case bit6E = 0x73
    case bit6H = 0x74
    case bit6L = 0x75
    case bit6_HL = 0x76
    case bit6A = 0x77
    case bit7B = 0x78
    case bit7C = 0x79
    case bit7D = 0x7A
    case bit7E = 0x7B
    case bit7H = 0x7C
    case bit7L = 0x7D
    case bit7_HL = 0x7E
    case bit7A = 0x7F
}

// MARK: - Opcode Execution
private extension CPU {
    func executeNextInstruction() -> Int {
        guard !halted else { return 1 }

        let opcode = fetchByte()
        logState(opcode: opcode)

        switch Opcode(rawValue: opcode) {
        case .nop: // NOP
            // Do nothing
            return 1
        case .ldBB:
            registers[.B] = registers[.B]
            return 1
        case .ldBC:
            registers[.B] = registers[.C]
            return 1
        case .ldBD:
            registers[.B] = registers[.D]
            return 1
        case .ldBE:
            registers[.B] = registers[.E]
            return 1
        case .ldBH:
            registers[.B] = registers[.H]
            return 1
        case .ldBL:
            registers[.B] = registers[.L]
            return 1
        case .ldBA:
            registers[.B] = registers[.A]
            return 1
        case .ldCB:
            registers[.C] = registers[.B]
            return 1
        case .ldCC:
            registers[.C] = registers[.C]
            return 1
        case .ldCD:
            registers[.C] = registers[.D]
            return 1
        case .ldCE:
            registers[.C] = registers[.E]
            return 1
        case .ldCH:
            registers[.C] = registers[.H]
            return 1
        case .ldCL:
            registers[.C] = registers[.L]
            return 1
        case .ldCA:
            registers[.C] = registers[.A]
            return 1
        case .ldDB:
            registers[.D] = registers[.B]
            return 1
        case .ldDC:
            registers[.D] = registers[.C]
            return 1
        case .ldDD:
            registers[.D] = registers[.D]
            return 1
        case .ldDE:
            registers[.D] = registers[.E]
            return 1
        case .ldDH:
            registers[.D] = registers[.H]
            return 1
        case .ldDL:
            registers[.D] = registers[.L]
            return 1
        case .ldDA:
            registers[.D] = registers[.A]
            return 1
        case .ldEB:
            registers[.E] = registers[.B]
            return 1
        case .ldEC:
            registers[.E] = registers[.C]
            return 1
        case .ldED:
            registers[.E] = registers[.D]
            return 1
        case .ldEE:
            registers[.E] = registers[.E]
            return 1
        case .ldEH:
            registers[.E] = registers[.H]
            return 1
        case .ldEL:
            registers[.E] = registers[.L]
            return 1
        case .ldEA:
            registers[.E] = registers[.A]
            return 1
        case .ldHB:
            registers[.H] = registers[.B]
            return 1
        case .ldHC:
            registers[.H] = registers[.C]
            return 1
        case .ldHD:
            registers[.H] = registers[.D]
            return 1
        case .ldHE:
            registers[.H] = registers[.E]
            return 1
        case .ldHH:
            registers[.H] = registers[.H]
            return 1
        case .ldHL:
            registers[.H] = registers[.L]
            return 1
        case .ldHA:
            registers[.H] = registers[.A]
            return 1
        case .ldLB:
            registers[.L] = registers[.B]
            return 1
        case .ldLC:
            registers[.L] = registers[.C]
            return 1
        case .ldLD:
            registers[.L] = registers[.D]
            return 1
        case .ldLE:
            registers[.L] = registers[.E]
            return 1
        case .ldLH:
            registers[.L] = registers[.H]
            return 1
        case .ldLL:
            registers[.L] = registers[.L]
            return 1
        case .ldLA:
            registers[.L] = registers[.A]
            return 1
        case .ldAB:
            registers[.A] = registers[.B]
            return 1
        case .ldAC:
            registers[.A] = registers[.C]
            return 1
        case .ldAD:
            registers[.A] = registers[.D]
            return 1
        case .ldAE:
            registers[.A] = registers[.E]
            return 1
        case .ldAH:
            registers[.A] = registers[.H]
            return 1
        case .ldAL:
            registers[.A] = registers[.L]
            return 1
        case .ldAA:
//            registers[.A] = registers[.A]
            return 1
        case .ldA_BC: // 0x0A — LD A,(BC)
            registers[.A] = mmu.read(BC)
            return 2
        case .ldA_DE: // 0x1A — LD A,(DE)
            registers[.A] = mmu.read(DE)
            return 2
        case .ldA_a8: // LD A, (a8)
            let off = fetchByte()
            let addr = UInt16(0xFF00) &+ UInt16(off)
            let m = mmu.read(addr)
//            print("LDH @FF00+\(String(format: "%02X", off)) → \(String(format: "%02X", m))")
            registers[.A] = m
            return 3
        case .ldB_d8: // LD B, n
            registers[.B] = fetchByte()
            return 2
        case .ldD_d8: // LD D, n
            registers[.D] = fetchByte()
            return 2
        case .ldH_d8: // LD H, n
            registers[.H] = fetchByte()
            return 2
        case .ldC_d8: // LD C, n
            registers[.C] = fetchByte()
            return 2
        case .ldE_d8: // LD E, n
            registers[.E] = fetchByte()
            return 2
        case .ldL_d8: // LD L, n
            registers[.L] = fetchByte()
            return 2
        case .ldA_d8: // LD A, n
            registers[.A] = fetchByte()
            return 2
        case .ldA_a16:
            let address = fetch2Bytes()
            registers[.A] = mmu.read(address)
            return 4
        case .ld_a8_A: // LD (a8), A
            let address = UInt16(0xFF00) &+ UInt16(fetchByte())
            mmu.write(registers[.A]!, to: address)
            return 3
        case .ld_a16_A: // LD (nn), A
            let address = fetch2Bytes()
            mmu.write(registers[.A]!, to: address)
            return 4
        case .ldC_A: // 0xE2 — LD (0xFF00+C), A
            let address = UInt16(0xFF00) &+ UInt16(registers[.C]!)
            mmu.write(registers[.A]!, to: address)
            return 2
        case .ldA_C: // 0xF2 — LD A,(0xFF00 + C)
            let address = UInt16(0xFF00) &+ UInt16(registers[.C]!)
            registers[.A] = mmu.read(address)
            return 2
        case .ldHL_d8:
            mmu.write(fetchByte(), to: HL)
            return 2
        case .ldHL_B:
            mmu.write(registers[.B]!, to: HL)
            return 2
        case .ldHL_C:
            mmu.write(registers[.C]!, to: HL)
            return 2
        case .ldHL_D:
            mmu.write(registers[.D]!, to: HL)
            return 2
        case .ldHL_E:
            mmu.write(registers[.E]!, to: HL)
            return 2
        case .ldHL_H:
            mmu.write(registers[.H]!, to: HL)
            return 2
        case .ldHL_L:
            mmu.write(registers[.L]!, to: HL)
            return 2
        case .ldHL_A:
            mmu.write(registers[.A]!, to: HL)
            return 2
        case .ldBC_A:
            mmu.write(registers[.A]!, to: BC)
            return 2
        case .ldDE_A:
            mmu.write(registers[.A]!, to: DE)
            return 2
        case .ldHL_inc_A:
            mmu.write(registers[.A]!, to: HL)
            HL &+= 1
            return 2
        case .ldHL_dec_A:
            mmu.write(registers[.A]!, to: HL)
            HL &-= 1
            return 2
        case .ldBC_d16: // LD BC, d16
            BC = fetch2Bytes()
            return 3
        case .ldDE_d16: // LD DE, d16
            DE = fetch2Bytes()
            return 3
        case .ldHL_d16: // LD HL, d16
            HL = fetch2Bytes()
            return 3
        case .ldSP_d16: // LD SP, d16
            SP = fetch2Bytes()
            return 3
        case .ldA_HL_inc:
            registers[.A] = mmu.read(HL)
            HL &+= 1
            return 2
        case .ldA_HL_dec:
            registers[.A] = mmu.read(HL)
            HL &-= 1
            return 2
        case .ldB_HL:
            registers[.B] = mmu.read(HL)
            return 2
        case .ldD_HL:
            registers[.D] = mmu.read(HL)
            return 2
        case .ldH_HL:
            registers[.H] = mmu.read(HL)
            return 2
        case .ldC_HL:
            registers[.C] = mmu.read(HL)
            return 2
        case .ldE_HL:
            registers[.E] = mmu.read(HL)
            return 2
        case .ldL_HL:
            registers[.L] = mmu.read(HL)
            return 2
        case .ldA_HL:
            registers[.A] = mmu.read(HL)
            return 2
        case .ldSP_HL:
            SP = HL
            return 2
        case .jp_a16: // JP a16
            PC = fetch2Bytes()
            return 4
        case .jr_s8:
            // Read signed 8-bit displacement
            let raw = fetchByte() // PC was incremented once for opcode fetch, now again for displacement
            let offset = Int8(bitPattern: raw) // Interpret as signed

            // PC now points to the next instruction; apply relative jump
            let newPC = Int32(PC) + Int32(offset) // PC is UInt16, cast to signed for addition
            PC = UInt16(truncatingIfNeeded: newPC) // Wrap-around on overflow, as hardware would

            return 3
        case .jrNZ_r8:
            // Read signed 8-bit displacement
            let raw = fetchByte() // PC was incremented once for opcode fetch, now again for displacement
            let offset = Int8(bitPattern: raw) // Interpret as signed

            if !Z {
                let delta = UInt16(bitPattern: Int16(offset))
                PC = PC &+ delta
                return 3
            }

            return 2
        case .jrNC_r8:
            // Read signed 8-bit displacement
            let raw = fetchByte() // PC was incremented once for opcode fetch, now again for displacement
            let offset = Int8(bitPattern: raw) // Interpret as signed

            if !C {
                let delta = UInt16(bitPattern: Int16(offset))
                PC = PC &+ delta
                return 3
            }

            return 2
        case .jrZ_r8:
            // Read signed 8-bit displacement
            let raw = fetchByte() // PC was incremented once for opcode fetch, now again for displacement
            let offset = Int8(bitPattern: raw) // Interpret as signed

            if Z {
                let delta = UInt16(bitPattern: Int16(offset))
                PC = PC &+ delta
                return 3
            }

            return 2
        case .jrC_r8:
            // Read signed 8-bit displacement
            let raw = fetchByte() // PC was incremented once for opcode fetch, now again for displacement
            let offset = Int8(bitPattern: raw) // Interpret as signed

            if C {
                let delta = UInt16(bitPattern: Int16(offset))
                PC = PC &+ delta
                return 3
            }

            return 2
        case .addAB:
            let first = registers[.A]!
            let second = registers[.B]!

            let sum16 = UInt16(first) + UInt16(second)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F)) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .addAC:
            let first = registers[.A]!
            let second = registers[.C]!

            let sum16 = UInt16(first) + UInt16(second)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F)) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .addAD:
            let first = registers[.A]!
            let second = registers[.D]!

            let sum16 = UInt16(first) + UInt16(second)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F)) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .addAE:
            let first = registers[.A]!
            let second = registers[.E]!

            let sum16 = UInt16(first) + UInt16(second)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F)) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .addAH:
            let first = registers[.A]!
            let second = registers[.H]!

            let sum16 = UInt16(first) + UInt16(second)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F)) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .addAL:
            let first = registers[.A]!
            let second = registers[.L]!

            let sum16 = UInt16(first) + UInt16(second)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F)) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .addA_HL:
            let first = registers[.A]!
            let second = mmu.read(HL)

            let sum16 = UInt16(first) + UInt16(second)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F)) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 2
        case .addAA:
            let a = registers[.A]!

            let sum16 = UInt16(a) + UInt16(a)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((a & 0x0F) + (a & 0x0F)) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .addA_d8:
            let oldA = registers[.A]!
            let value = fetchByte()
            let sum16 = UInt16(oldA) + UInt16(value)
            let result = UInt8(truncatingIfNeeded: sum16)
            registers[.A] = result

            Z = result == 0
            N = false
            H = ((oldA & 0xF) + (value & 0xF)) > 0xF
            C = sum16 > 0xFF

            return 2
        case .sub_d8:
            let oldA = registers[.A]!
            let value = fetchByte()
            let result = oldA &- value
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < (value & 0xF)
            C = oldA < value

            return 2
        case .xorB: // XOR B
            let result = registers[.A]! ^ registers[.B]!
            registers[.A] = result

            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .xorC: // XOR C
            let result = registers[.A]! ^ registers[.C]!
            registers[.A] = result

            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .xorD: // XOR D
            let result = registers[.A]! ^ registers[.D]!
            registers[.A] = result

            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .xorE: // XOR E
            let result = registers[.A]! ^ registers[.E]!
            registers[.A] = result

            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .xorH: // XOR H
            let result = registers[.A]! ^ registers[.H]!
            registers[.A] = result

            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .xorL: // XOR L
            let result = registers[.A]! ^ registers[.L]!
            registers[.A] = result

            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .xor_HL: // XOR HL
            let result = registers[.A]! ^ mmu.read(HL)
            registers[.A] = result

            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 2
        case .xorA: // XOR A
            let a = registers[.A]!
            let result = a ^ a
            registers[.A] = result
            registers[.F] = 1 << 7 // set Zero flag
            return 1
        case .xorA_d8: // XOR A D8
            let result = registers[.A]! ^ fetchByte()
            registers[.A] = result
            setFlags(z: result == 0, n: false, h: false, c: false)
            return 2
        case .orB:
            let result = registers[.A]! | registers[.B]!
            registers[.A] = result
            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .orC:
            let result = registers[.A]! | registers[.C]!
            registers[.A] = result
            registers[.F] = (result == 0) ? 0b1000_0000 : 0
            return 1
        case .orD:
            let result = registers[.A]! | registers[.D]!
            registers[.A] = result
            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .orE:
            let result = registers[.A]! | registers[.E]!
            registers[.A] = result
            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .orH:
            let result = registers[.A]! | registers[.H]!
            registers[.A] = result
            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .orL:
            let result = registers[.A]! | registers[.L]!
            registers[.A] = result
            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .orA:
            let result = registers[.A]!
//            registers[.A] = result // It's the same
            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .and_d8:
            let value = fetchByte()
            let result = registers[.A]! & value
            registers[.A] = result
            Z = result == 0
            N = false
            H = true
            C = false
            return 2
        case .call_a16:
            let address = fetch2Bytes()

            // Push current PC (which points to next instruction) onto the stack
            SP &-= 1
            mmu.write(UInt8((PC >> 8) & 0xFF), to: SP) // High byte
            SP &-= 1
            mmu.write(UInt8(PC & 0xFF), to: SP) // Low byte

            // Jump to address
            PC = address
            return 6
        case .callNZ_a16:
            let address = fetch2Bytes()
            if !Z {
                SP &-= 1
                mmu.write(UInt8((PC >> 8) & 0xFF), to: SP) // High byte
                SP &-= 1
                mmu.write(UInt8(PC & 0xFF), to: SP) // Low byte

                // Jump to address
                PC = address
                return 6
            }

            return 3
        case .retNZ:
            if !Z {
                PC = pop16()
                return 5
            }
            return 2
        case .retZ:
            if Z {
                PC = pop16()
                return 5
            }
            return 2
        case .retNC:
            if !C {
                PC = pop16()
                return 5
            }
            return 2
        case .retC:
            if C {
                PC = pop16()
                return 5
            }
            return 2
        case .ret:
            PC = pop16()
            return 4
        case .retI:
            PC = pop16()
            interruptMasterEnable = true
            return 4
        case .pushAF:
            let af = AF

            SP &-= 1
            mmu.write(UInt8((af >> 8) & 0xFF), to: SP)
            SP &-= 1
            mmu.write(UInt8(af & 0xFF), to: SP)

            return 4
        case .pushBC:
            let bc = BC

            SP &-= 1
            mmu.write(UInt8((bc >> 8) & 0xFF), to: SP)
            SP &-= 1
            mmu.write(UInt8(bc & 0xFF), to: SP)

            return 4
        case .pushDE:
            let de = DE

            SP &-= 1
            mmu.write(UInt8((de >> 8) & 0xFF), to: SP)
            SP &-= 1
            mmu.write(UInt8(de & 0xFF), to: SP)

            return 4
        case .pushHL:
            let hl = HL

            SP &-= 1
            mmu.write(UInt8((hl >> 8) & 0xFF), to: SP)
            SP &-= 1
            mmu.write(UInt8(hl & 0xFF), to: SP)

            return 4
        case .popAF:
            AF = pop16()
            return 3
        case .popBC:
            BC = pop16()
            return 3
        case .popDE:
            DE = pop16()
            return 3
        case .popHL:
            HL = pop16()
            return 3
        case .incH:
            let old = registers[.H]!
            let value = old &+ 1
            registers[.H] = value
            Z = value == 0
            N = false
            H = (old & 0x0F) == 0x0F
            return 1
        case .incD:
            let old = registers[.D]!
            let value = old &+ 1
            registers[.D] = value
            Z = value == 0
            N = false
            H = (old & 0x0F) == 0x0F
            return 1
        case .incB:
            let old = registers[.B]!
            let value = old &+ 1
            registers[.B] = value
            Z = value == 0
            N = false
            H = (old & 0x0F) == 0x0F
            return 1
        case .incC:
            let old = registers[.C]!
            let value = old &+ 1
            registers[.C] = value
            Z = value == 0
            N = false
            H = (old & 0x0F) == 0x0F
            return 1
        case .incE:
            let old = registers[.E]!
            let value = old &+ 1
            registers[.E] = value
            Z = value == 0
            N = false
            H = (old & 0x0F) == 0x0F
            return 1
        case .incA:
            let old = registers[.A]!
            let value = old &+ 1
            registers[.A] = value
            Z = value == 0
            N = false
            H = (old & 0x0F) == 0x0F
            return 1
        case .incL:
            let old = registers[.L]!
            let value = old &+ 1
            registers[.L] = value
            Z = value == 0
            N = false
            H = (old & 0x0F) == 0x0F
            return 1
        case .decB:
            let old = registers[.B]!
            let value = old &- 1
            registers[.B] = value
            Z = value == 0
            N = true
            H = (old & 0x0F) == 0x00
            return 1
        case .decD:
            let old = registers[.D]!
            let value = old &- 1
            registers[.D] = value
            Z = value == 0
            N = true
            H = (old & 0x0F) == 0x00
            return 1
        case .decH:
            let old = registers[.H]!
            let value = old &- 1
            registers[.H] = value
            Z = value == 0
            N = true
            H = (old & 0x0F) == 0x00
            return 1
        case .decC:
            let old = registers[.C]!
            let value = old &- 1
            registers[.C] = value
            Z = value == 0
            N = true
            H = (old & 0x0F) == 0x00
            return 1
        case .decE:
            let old = registers[.E]!
            let value = old &- 1
            registers[.E] = value
            Z = value == 0
            N = true
            H = (old & 0x0F) == 0x00
            return 1
        case .decL:
            let old = registers[.L]!
            let value = old &- 1
            registers[.L] = value
            Z = value == 0
            N = true
            H = (old & 0x0F) == 0x00
            return 1
        case .decA:
            let old = registers[.A]!
            let value = old &- 1
            registers[.A] = value
            Z = value == 0
            N = true
            H = (old & 0x0F) == 0x00
            return 1
        case .incBC:
            BC &+= 1
            return 2
        case .incDE:
            DE &+= 1
            return 2
        case .incHL:
            HL &+= 1
            return 2
        case .incSP:
            SP &+= 1
            return 2
        case .cp_d8: // CP d8
            let value = fetchByte()
            let a = registers[.A]!
            let res = a &- value

            // Flags:
            Z = res == 0 // Z: set if result is zero
            N = true // N: set (because it's a subtraction)
            H = (a & 0xF) < (value & 0xF) // H: set if there was a borrow from bit 4 (a&0xF < value&0xF)
            C = a < value // C: set if there was a borrow (a < value)

//            print("CP A(\(String(format: "%02X", a))) - \(String(format: "%02X", value)) = \(String(format: "%02X", res))",
//                  "flags Z\(Z) N\(N) H\(H) C\(C)")

            return 2
        case .rra:
            let old = registers[.A]!
            registers[.A] = (old >> 1) | (C ? 0x80 : 0x00)

            let lsb = (old & 0x01) != 0
            setFlags(z: false, n: false, h: false, c: lsb)
            return 1
        case .di: // DI
            interruptMasterEnable = false
            return 1
        case .ei: // EI
            interruptMasterEnable = true
            return 1
        case .stop:
            _ = fetchByte()
            stopped = true
            mmu.write(0, to: 0xFF04) // Divider reset
            print("CPU stopped")
            return 1
        case .cb:
            return executeNextCBInstruction()
        case .none:
            print("Unknown opcode: \(String(format: "%02X", opcode)) at PC: \(String(format: "%04X", PC - 1))")
            halted = true
            return 1
        }
    }

    func executeNextCBInstruction() -> Int {
        let opcode = fetchByte()
        logState(opcode: opcode)

        switch CBOpcode(rawValue: opcode) {
        case .rlcB:
            fatalError()
        case .rrB:
            let old = registers[.B]!
            let result = (old >> 1) | (C ? 0x80 : 0x00)
            registers[.B] = result

            let lsb = (old & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: lsb)
            return 2
        case .rrC:
            let old = registers[.C]!
            let result = (old >> 1) | (C ? 0x80 : 0x00)
            registers[.C] = result

            let lsb = (old & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: lsb)
            return 2
        case .rrD:
            let old = registers[.D]!
            let result = (old >> 1) | (C ? 0x80 : 0x00)
            registers[.D] = result

            let lsb = (old & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: lsb)
            return 2
        case .rrE:
            let old = registers[.E]!
            let result = (old >> 1) | (C ? 0x80 : 0x00)
            registers[.E] = result

            let lsb = (old & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: lsb)
            return 2
        case .rrH:
            let old = registers[.H]!
            let result = (old >> 1) | (C ? 0x80 : 0x00)
            registers[.H] = result

            let lsb = (old & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: lsb)
            return 2
        case .rrL:
            let old = registers[.L]!
            let result = (old >> 1) | (C ? 0x80 : 0x00)
            registers[.L] = result

            let lsb = (old & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: lsb)
            return 2
        case .rrA:
            let old = registers[.A]!
            let result = (old >> 1) | (C ? 0x80 : 0x00)
            registers[.A] = result

            let lsb = (old & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: lsb)
            return 2
        case .slaB:
            let CY = registers[.B]! >> 7 & 1 == 1
            let result = registers[.B]! << 1
            registers[.B] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .slaC:
            let CY = registers[.C]! >> 7 & 1 == 1
            let result = registers[.C]! << 1
            registers[.C] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .slaD:
            let CY = registers[.D]! >> 7 & 1 == 1
            let result = registers[.D]! << 1
            registers[.D] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .slaE:
            let CY = registers[.E]! >> 7 & 1 == 1
            let result = registers[.E]! << 1
            registers[.E] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .slaH:
            let CY = registers[.H]! >> 7 & 1 == 1
            let result = registers[.H]! << 1
            registers[.H] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .slaL:
            let CY = registers[.L]! >> 7 & 1 == 1
            let result = registers[.L]! << 1
            registers[.L] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .slaA:
            let CY = registers[.A]! >> 7 & 1 == 1
            let result = registers[.A]! << 1
            registers[.A] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .srlB:
            let CY = registers[.B]! & 1 == 1
            let result = registers[.B]! >> 1
            registers[.B] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .bit0B:
            return testBit(0, in: registers[.B]!)
        case .bit0C:
            return testBit(0, in: registers[.C]!)
        case .bit0D:
            return testBit(0, in: registers[.D]!)
        case .bit0E:
            return testBit(0, in: registers[.E]!)
        case .bit0H:
            return testBit(0, in: registers[.H]!)
        case .bit0L:
            return testBit(0, in: registers[.L]!)
        case .bit0_HL:
            return testBit(0, in: mmu.read(HL)) + 1
        case .bit0A:
            return testBit(0, in: registers[.A]!)
        case .bit1B:
            return testBit(1, in: registers[.B]!)
        case .bit1C:
            return testBit(1, in: registers[.C]!)
        case .bit1D:
            return testBit(1, in: registers[.D]!)
        case .bit1E:
            return testBit(1, in: registers[.E]!)
        case .bit1H:
            return testBit(1, in: registers[.H]!)
        case .bit1L:
            return testBit(1, in: registers[.L]!)
        case .bit1_HL:
            return testBit(1, in: mmu.read(HL)) + 1
        case .bit1A:
            return testBit(1, in: registers[.A]!)
        case .bit2B:
            return testBit(2, in: registers[.B]!)
        case .bit2C:
            return testBit(2, in: registers[.C]!)
        case .bit2D:
            return testBit(2, in: registers[.D]!)
        case .bit2E:
            return testBit(2, in: registers[.E]!)
        case .bit2H:
            return testBit(2, in: registers[.H]!)
        case .bit2L:
            return testBit(2, in: registers[.L]!)
        case .bit2_HL:
            return testBit(2, in: mmu.read(HL)) + 1
        case .bit2A:
            return testBit(2, in: registers[.A]!)
        case .bit3B:
            return testBit(3, in: registers[.B]!)
        case .bit3C:
            return testBit(3, in: registers[.C]!)
        case .bit3D:
            return testBit(3, in: registers[.D]!)
        case .bit3E:
            return testBit(3, in: registers[.E]!)
        case .bit3H:
            return testBit(3, in: registers[.H]!)
        case .bit3L:
            return testBit(3, in: registers[.L]!)
        case .bit3_HL:
            return testBit(3, in: mmu.read(HL)) + 1
        case .bit3A:
            return testBit(3, in: registers[.A]!)
        case .bit4B:
            return testBit(4, in: registers[.B]!)
        case .bit4C:
            return testBit(4, in: registers[.C]!)
        case .bit4D:
            return testBit(4, in: registers[.D]!)
        case .bit4E:
            return testBit(4, in: registers[.E]!)
        case .bit4H:
            return testBit(4, in: registers[.H]!)
        case .bit4L:
            return testBit(4, in: registers[.L]!)
        case .bit4_HL:
            return testBit(4, in: mmu.read(HL)) + 1
        case .bit4A:
            return testBit(4, in: registers[.A]!)
        case .bit5B:
            return testBit(5, in: registers[.B]!)
        case .bit5C:
            return testBit(5, in: registers[.C]!)
        case .bit5D:
            return testBit(5, in: registers[.D]!)
        case .bit5E:
            return testBit(5, in: registers[.E]!)
        case .bit5H:
            return testBit(5, in: registers[.H]!)
        case .bit5L:
            return testBit(5, in: registers[.L]!)
        case .bit5_HL:
            return testBit(5, in: mmu.read(HL)) + 1
        case .bit5A:
            return testBit(5, in: registers[.A]!)
        case .bit6B:
            return testBit(6, in: registers[.B]!)
        case .bit6C:
            return testBit(6, in: registers[.C]!)
        case .bit6D:
            return testBit(6, in: registers[.D]!)
        case .bit6E:
            return testBit(6, in: registers[.E]!)
        case .bit6H:
            return testBit(6, in: registers[.H]!)
        case .bit6L:
            return testBit(6, in: registers[.L]!)
        case .bit6_HL:
            return testBit(6, in: mmu.read(HL)) + 1
        case .bit6A:
            return testBit(6, in: registers[.A]!)
        case .bit7B:
            return testBit(7, in: registers[.B]!)
        case .bit7C:
            return testBit(7, in: registers[.C]!)
        case .bit7D:
            return testBit(7, in: registers[.D]!)
        case .bit7E:
            return testBit(7, in: registers[.E]!)
        case .bit7H:
            return testBit(7, in: registers[.H]!)
        case .bit7L:
            return testBit(7, in: registers[.L]!)
        case .bit7_HL:
            return testBit(7, in: mmu.read(HL)) + 1
        case .bit7A:
            return testBit(7, in: registers[.A]!)
        case .none:
            print("Unknown CB opcode: \(String(format: "%02X", opcode)) at PC: \(String(format: "%04X", PC - 1))")
            halted = true
            return 1
        }
    }

    func testBit(_ b: Int, in value: UInt8) -> Int {
        let bit = (value >> b) & 1 == 1
        setFlags(z: !bit, n: false, h: true, c: C)
        return 2
    }
}

class CPU {
    init(mmu: MMU) {
        self.mmu = mmu
    }

    var registers: [Register: UInt8] = [
        .A: 0x01, .F: 0xB0, .B: 0x00, .C: 0x13,
        .D: 0x00, .E: 0xD8, .H: 0x01, .L: 0x4D
    ]

    var PC: UInt16 = 0x0100
    var SP: UInt16 = 0xFFFE

    let mmu: MMU
    var interruptMasterEnable = false
    private(set) var halted = false
    private(set) var stopped = false

    // MARK: - Helpers
    var AF: UInt16 {
        get { (UInt16(registers[.A]!) << 8) | UInt16(registers[.F]!) }
        set {
            registers[.A] = UInt8((newValue >> 8) & 0xFF)
            registers[.F] = UInt8(newValue & 0xF0) // lower 4 bits unused
        }
    }

    var BC: UInt16 {
        get { (UInt16(registers[.B]!) << 8) | UInt16(registers[.C]!) }
        set {
            registers[.B] = UInt8((newValue >> 8) & 0xFF)
            registers[.C] = UInt8(newValue & 0xF0) // lower 4 bits unused
        }
    }

    var DE: UInt16 {
        get { (UInt16(registers[.D]!) << 8) | UInt16(registers[.E]!) }
        set {
            registers[.D] = UInt8((newValue >> 8) & 0xFF)
            registers[.E] = UInt8(newValue & 0xF0) // lower 4 bits unused
        }
    }

    var HL: UInt16 {
        get { (UInt16(registers[.H]!) << 8) | UInt16(registers[.L]!) }
        set {
            registers[.H] = UInt8((newValue >> 8) & 0xFF)
            registers[.L] = UInt8(newValue & 0xF0) // lower 4 bits unused
        }
    }

    func setFlags(z: Bool, n: Bool, h: Bool, c: Bool) {
        Z = z
        N = n
        H = h
        C = c
    }

    // Z flag
    var Z: Bool {
        get { return (registers[.F]! & 0b1000_0000) != 0 }
        set { registers[.F]! = newValue ? (registers[.F]! | 0b1000_0000) : (registers[.F]! & 0b0111_1111) }
    }

    // N flag
    var N: Bool {
        get { return (registers[.F]! & 0b0100_0000) != 0 }
        set { registers[.F]! = newValue ? (registers[.F]! | 0b0100_0000) : (registers[.F]! & 0b1011_1111) }
    }

    // H flag
    var H: Bool {
        get { return (registers[.F]! & 0b0010_0000) != 0 }
        set { registers[.F]! = newValue ? (registers[.F]! | 0b0010_0000) : (registers[.F]! & 0b1101_1111) }
    }

    // C flag
    var C: Bool {
        get { return (registers[.F]! & 0b0001_0000) != 0 }
        set { registers[.F]! = newValue ? (registers[.F]! | 0b0001_0000) : (registers[.F]! & 0b1110_1111) }
    }

    func readByte(at address: UInt16) -> UInt8 {
        return mmu.read(address)
    }

    func writeByte(_ byte: UInt8, at address: UInt16) {
        mmu.write(byte, to: address)
    }

    func fetchByte() -> UInt8 {
        let byte = readByte(at: PC)
        PC += 1
        return byte
    }

    func fetch2Bytes() -> UInt16 {
        let low = fetchByte()
        let high = fetchByte()
        return UInt16(high) << 8 | UInt16(low)
    }

    func pop16() -> UInt16 {
        let low  = mmu.read(SP); SP &+= 1
        let high = mmu.read(SP); SP &+= 1
        return (UInt16(high) << 8) | UInt16(low)
    }

    // MARK: - Step
    func step() -> Int {
        return executeNextInstruction() * 4
    }

    private func logState(opcode: UInt8) {
//        return

        let flags = registers[.F]!
        func fbit(_ bit: Int) -> Int { Int((flags >> bit) & 1) }

        print(String(
            format: "PC:%04X  OP:%02X  A:%02X F:%02X B:%02X C:%02X D:%02X E:%02X H:%02X L:%02X SP:%04X Z:%d N:%d H:%d C:%d",
            PC - 1, opcode,
            registers[.A]!, flags,
            registers[.B]!, registers[.C]!,
            registers[.D]!, registers[.E]!,
            registers[.H]!, registers[.L]!,
            SP,
            fbit(7), fbit(6), fbit(5), fbit(4)
        ))
    }
}

extension CPU {
    func checkStopState() -> Bool {
        if stopped {
            // spin (or sleep) until a key-press un-stops us
            if isButtonDown {
                stopped = false
            } else {
                // yield CPU so we don't busy‐spin at 100%
                Thread.sleep(forTimeInterval: 0.01)
            }
            return false
        }

        return true
    }

    private var isButtonDown: Bool {
        mmu.joypadState != 0xFF
    }
}

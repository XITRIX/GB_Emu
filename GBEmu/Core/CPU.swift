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
//    case ldAB = 0xAB
    case ldAE = 0x7B
    case ldAL = 0x7D
    case ldAH = 0x7C
    case ldAN = 0x3E
    case ldBN = 0x06
    case ldCN = 0x0E
    case ldNA = 0xE0
    case ldNNA = 0xEA
    case ldBCNN = 0x01
    case ldDENN = 0x11
    case ldHLNN = 0x21
    case ldSPNN = 0x31
    case ldA_HL = 0x2A
    case jpNN = 0xC3
    case jrN = 0x18
    case xorA = 0xAF
    case xorE = 0xAB
    case callNN = 0xCD
    case ret = 0xC9
    case pushAF = 0xF5
    case pushBC = 0xC5
    case pushDE = 0xD5
    case pushHL = 0xE5
    case popAF = 0xF1
    case popBC = 0xC1
    case popDE = 0xD1
    case popHL = 0xE1
//    case incB = 0x04
//    case incD = 0x14
//    case incH = 0x24
    case incBC = 0x03
    case incDE = 0x13
    case incHL = 0x23
    case incSP = 0x33
    case di = 0xF3
    case ei = 0xFB
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
        case .ldAE:
            registers[.A] = registers[.E]
            return 1
        case .ldAL:
            registers[.A] = registers[.L]
            return 1
        case .ldAH:
            registers[.A] = registers[.H]
            return 1
        case .ldAN: // LD A, n
            registers[.A] = fetchByte()
            return 2
        case .ldBN: // LD B, n
            registers[.B] = fetchByte()
            return 2
        case .ldCN: // LD C, n
            registers[.C] = fetchByte()
            return 2
        case .ldNA: // LD (a8), A
            let address: UInt16 = 0xFF00 | UInt16(fetchByte())
            mmu.write(registers[.A]!, to: address)
            return 3
        case .ldNNA: // LD (nn), A
            let address = fetch2Bytes()
            mmu.write(registers[.A]!, to: address)
            return 4
        case .ldBCNN: // LD BC, d16
            BC = fetch2Bytes()
            return 3
        case .ldDENN: // LD DE, d16
            DE = fetch2Bytes()
            return 3
        case .ldHLNN: // LD HL, d16
            HL = fetch2Bytes()
            return 3
        case .ldSPNN: // LD SP, d16
            SP = fetch2Bytes()
            return 3
        case .ldA_HL:
            registers[.A] = mmu.read(HL)
            HL &+= 1
            return 2
        case .jpNN: // JP a16
            PC = fetch2Bytes()
            return 4
        case .jrN:
            // Read signed 8-bit displacement
            let raw = fetchByte()                    // PC was incremented once for opcode fetch, now again for displacement
            let offset = Int8(bitPattern: raw)       // Interpret as signed

            // PC now points to the next instruction; apply relative jump
            let newPC = Int32(PC) + Int32(offset)    // PC is UInt16, cast to signed for addition
            PC = UInt16(truncatingIfNeeded: newPC)   // Wrap-around on overflow, as hardware would

            return 3
        case .xorA: // XOR A
            let a = registers[.A]!
            let result = a ^ a
            registers[.A] = result
            registers[.F] = 1 << 7 // set Zero flag
            return 1
        case .xorE: // XOR E
            let result = registers[.A]! ^ registers[.E]!
            registers[.A] = result

            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .callNN:
            let address = fetch2Bytes()

            // Push current PC (which points to next instruction) onto the stack
            SP &-= 1
            mmu.write(UInt8((PC >> 8) & 0xFF), to: SP) // High byte
            SP &-= 1
            mmu.write(UInt8(PC & 0xFF), to: SP)        // Low byte

            // Jump to address
            PC = address
            return 6
        case .ret:
            let low = mmu.read(SP)
            SP &+= 1
            let high = mmu.read(SP)
            SP &+= 1

            PC = (UInt16(high) << 8) | UInt16(low)

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
            let low = mmu.read(SP)
            SP &+= 1
            let high = mmu.read(SP)
            SP &+= 1

            AF = UInt16(high) << 8 | UInt16(low)

            return 3
        case .popBC:
            let low = mmu.read(SP)
            SP &+= 1
            let high = mmu.read(SP)
            SP &+= 1

            BC = UInt16(high) << 8 | UInt16(low)

            return 3
        case .popDE:
            let low = mmu.read(SP)
            SP &+= 1
            let high = mmu.read(SP)
            SP &+= 1

            DE = UInt16(high) << 8 | UInt16(low)

            return 3
        case .popHL:
            let low = mmu.read(SP)
            SP &+= 1
            let high = mmu.read(SP)
            SP &+= 1

            HL = UInt16(high) << 8 | UInt16(low)

            return 3
        case .incBC:
            BC += 1
            return 2
        case .incDE:
            DE += 1
            return 2
        case .incHL:
            HL += 1
            return 2
        case .incSP:
            SP += 1
            return 2
        case .di: // DI
            interruptMasterEnable = false
            return 1
        case .ei: // EI
            interruptMasterEnable = true
            return 1
        case .none:
            print("Unknown opcode: \(String(format: "%02X", opcode)) at PC: \(String(format: "%04X", PC - 1))")
            halted = true
            return 1
        }
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
    var halted = false

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

    // MARK: - Step
    func step() -> Int {
        return executeNextInstruction() * 4
    }

    private func logState(opcode: UInt8) {
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

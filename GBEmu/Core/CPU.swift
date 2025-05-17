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
    case ldHL_SP_s8 = 0xF8
    case ldSP_HL = 0xF9
    case ld_a16_SP = 0x08
    case jp_a16 = 0xC3
    case jpNZ_a16 = 0xC2
    case jpZ_a16 = 0xCA
    case jpNC_a16 = 0xD2
    case jpC_a16 = 0xDA
    case jpHL = 0xE9
    case jr_s8 = 0x18
    case jrNZ_r8 = 0x20
    case jrNC_r8 = 0x30
    case jrZ_r8 = 0x28
    case jrC_r8 = 0x38
    case daa = 0x27
    case scf = 0x37
    case cpl = 0x2F
    case ccf = 0x3F
    case addAB = 0x80
    case addAC = 0x81
    case addAD = 0x82
    case addAE = 0x83
    case addAH = 0x84
    case addAL = 0x85
    case addA_HL = 0x86
    case addAA = 0x87
    case addA_d8 = 0xC6
    case addHL_BC = 0x09
    case addHL_DE = 0x19
    case addHL_HL = 0x29
    case addHL_SP = 0x39
    case addSP_s8 = 0xE8
    case adcAB = 0x88
    case adcAC = 0x89
    case adcAD = 0x8A
    case adcAE = 0x8B
    case adcAH = 0x8C
    case adcAL = 0x8D
    case adc_HL = 0x8E
    case adcAA = 0x8F
    case adc_d8 = 0xCE
    case subB = 0x90
    case subC = 0x91
    case subD = 0x92
    case subE = 0x93
    case subH = 0x94
    case subL = 0x95
    case sub_HL = 0x96
    case subA = 0x97
    case sub_d8 = 0xD6
    case sbcAB = 0x98
    case sbcAC = 0x99
    case sbcAD = 0x9A
    case sbcAE = 0x9B
    case sbcAH = 0x9C
    case sbcAL = 0x9D
    case sbcA_HL = 0x9E
    case sbcAA = 0x9F
    case sbcA_d8 = 0xDE
    case andB = 0xA0
    case andC = 0xA1
    case andD = 0xA2
    case andE = 0xA3
    case andH = 0xA4
    case andL = 0xA5
    case and_HL = 0xA6
    case andA = 0xA7
    case and_d8 = 0xE6
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
    case or_HL = 0xB6
    case orA = 0xB7
    case or_d8 = 0xF6
    case cpB = 0xB8
    case cpC = 0xB9
    case cpD = 0xBA
    case cpE = 0xBB
    case cpH = 0xBC
    case cpL = 0xBD
    case cp_HL = 0xBE
    case cpA = 0xBF
    case rst0 = 0xC7
    case rst1 = 0xCF
    case rst2 = 0xD7
    case rst3 = 0xDF
    case rst4 = 0xE7
    case rst5 = 0xEF
    case rst6 = 0xF7
    case rst7 = 0xFF
    case call_a16 = 0xCD
    case callZ_a16 = 0xCC
    case callNZ_a16 = 0xC4
    case callC_a16 = 0xDC
    case callNC_a16 = 0xD4
    case ret = 0xC9
    case retZ = 0xC8
    case retNZ = 0xC0
    case retC = 0xD8
    case retNC = 0xD0
    case retI = 0xD9
    case pushBC = 0xC5
    case pushDE = 0xD5
    case pushHL = 0xE5
    case pushAF = 0xF5
    case popBC = 0xC1
    case popDE = 0xD1
    case popHL = 0xE1
    case popAF = 0xF1
    case decBC = 0x0B
    case decDE = 0x1B
    case decHL = 0x2B
    case decSP = 0x3B
    case incB = 0x04
    case incD = 0x14
    case incH = 0x24
    case incC = 0x0C
    case incE = 0x1C
    case incL = 0x2C
    case incA = 0x3C
    case inc_HL = 0x34
    case decB = 0x05
    case decD = 0x15
    case decH = 0x25
    case decC = 0x0D
    case decE = 0x1D
    case decL = 0x2D
    case decA = 0x3D
    case dec_HL = 0x35
    case incBC = 0x03
    case incDE = 0x13
    case incHL = 0x23
    case incSP = 0x33
    case cp_d8 = 0xFE
    case rlca = 0x07
    case rla = 0x17
    case rrca = 0x0F
    case rra = 0x1F
    case di = 0xF3
    case ei = 0xFB
    case stop = 0x10
    case halt = 0x76
    case cb = 0xCB
}

enum CBOpcode: UInt8 {
    case rlcB = 0x00
    case rlcC = 0x01
    case rlcD = 0x02
    case rlcE = 0x03
    case rlcH = 0x04
    case rlcL = 0x05
    case rlc_HL = 0x06
    case rlcA = 0x07
    case rrcB = 0x08
    case rrcC = 0x09
    case rrcD = 0x0A
    case rrcE = 0x0B
    case rrcH = 0x0C
    case rrcL = 0x0D
    case rrc_HL = 0x0E
    case rrcA = 0x0F
    case rlB = 0x10
    case rlC = 0x11
    case rlD = 0x12
    case rlE = 0x13
    case rlH = 0x14
    case rlL = 0x15
    case rl_HL = 0x16
    case rlA = 0x17
    case rrB = 0x18
    case rrC = 0x19
    case rrD = 0x1A
    case rrE = 0x1B
    case rrH = 0x1C
    case rrL = 0x1D
    case rr_HL = 0x1E
    case rrA = 0x1F
    case slaB = 0x20
    case slaC = 0x21
    case slaD = 0x22
    case slaE = 0x23
    case slaH = 0x24
    case slaL = 0x25
    case sla_HL = 0x26
    case slaA = 0x27
    case sraB = 0x28
    case sraC = 0x29
    case sraD = 0x2A
    case sraE = 0x2B
    case sraH = 0x2C
    case sraL = 0x2D
    case sra_HL = 0x2E
    case sraA = 0x2F
    case swapB = 0x30
    case swapC = 0x31
    case swapD = 0x32
    case swapE = 0x33
    case swapH = 0x34
    case swapL = 0x35
    case swap_HL = 0x36
    case swapA = 0x37
    case srlB = 0x38
    case srlC = 0x39
    case srlD = 0x3A
    case srlE = 0x3B
    case srlH = 0x3C
    case srlL = 0x3D
    case srl_HL = 0x3E
    case srlA = 0x3F
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
    case res0B = 0x80
    case res0C = 0x81
    case res0D = 0x82
    case res0E = 0x83
    case res0H = 0x84
    case res0L = 0x85
    case res0_HL = 0x86
    case res0A = 0x87
    case res1B = 0x88
    case res1C = 0x89
    case res1D = 0x8A
    case res1E = 0x8B
    case res1H = 0x8C
    case res1L = 0x8D
    case res1_HL = 0x8E
    case res1A = 0x8F
    case res2B = 0x90
    case res2C = 0x91
    case res2D = 0x92
    case res2E = 0x93
    case res2H = 0x94
    case res2L = 0x95
    case res2_HL = 0x96
    case res2A = 0x97
    case res3B = 0x98
    case res3C = 0x99
    case res3D = 0x9A
    case res3E = 0x9B
    case res3H = 0x9C
    case res3L = 0x9D
    case res3_HL = 0x9E
    case res3A = 0x9F
    case res4B = 0xA0
    case res4C = 0xA1
    case res4D = 0xA2
    case res4E = 0xA3
    case res4H = 0xA4
    case res4L = 0xA5
    case res4_HL = 0xA6
    case res4A = 0xA7
    case res5B = 0xA8
    case res5C = 0xA9
    case res5D = 0xAA
    case res5E = 0xAB
    case res5H = 0xAC
    case res5L = 0xAD
    case res5_HL = 0xAE
    case res5A = 0xAF
    case res6B = 0xB0
    case res6C = 0xB1
    case res6D = 0xB2
    case res6E = 0xB3
    case res6H = 0xB4
    case res6L = 0xB5
    case res6_HL = 0xB6
    case res6A = 0xB7
    case res7B = 0xB8
    case res7C = 0xB9
    case res7D = 0xBA
    case res7E = 0xBB
    case res7H = 0xBC
    case res7L = 0xBD
    case res7_HL = 0xBE
    case res7A = 0xBF
    case set0B = 0xC0
    case set0C = 0xC1
    case set0D = 0xC2
    case set0E = 0xC3
    case set0H = 0xC4
    case set0L = 0xC5
    case set0_HL = 0xC6
    case set0A = 0xC7
    case set1B = 0xC8
    case set1C = 0xC9
    case set1D = 0xCA
    case set1E = 0xCB
    case set1H = 0xCC
    case set1L = 0xCD
    case set1_HL = 0xCE
    case set1A = 0xCF
    case set2B = 0xD0
    case set2C = 0xD1
    case set2D = 0xD2
    case set2E = 0xD3
    case set2H = 0xD4
    case set2L = 0xD5
    case set2_HL = 0xD6
    case set2A = 0xD7
    case set3B = 0xD8
    case set3C = 0xD9
    case set3D = 0xDA
    case set3E = 0xDB
    case set3H = 0xDC
    case set3L = 0xDD
    case set3_HL = 0xDE
    case set3A = 0xDF
    case set4B = 0xE0
    case set4C = 0xE1
    case set4D = 0xE2
    case set4E = 0xE3
    case set4H = 0xE4
    case set4L = 0xE5
    case set4_HL = 0xE6
    case set4A = 0xE7
    case set5B = 0xE8
    case set5C = 0xE9
    case set5D = 0xEA
    case set5E = 0xEB
    case set5H = 0xEC
    case set5L = 0xED
    case set5_HL = 0xEE
    case set5A = 0xEF
    case set6B = 0xF0
    case set6C = 0xF1
    case set6D = 0xF2
    case set6E = 0xF3
    case set6H = 0xF4
    case set6L = 0xF5
    case set6_HL = 0xF6
    case set6A = 0xF7
    case set7B = 0xF8
    case set7C = 0xF9
    case set7D = 0xFA
    case set7E = 0xFB
    case set7H = 0xFC
    case set7L = 0xFD
    case set7_HL = 0xFE
    case set7A = 0xFF
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
        case .ldHL_SP_s8:
            let offset = Int8(bitPattern: fetchByte())
            let sp = SP

            let result = UInt16(bitPattern: Int16(truncatingIfNeeded: Int32(sp) &+ Int32(offset)))

            let spLow = UInt16(sp & 0x00FF)
            let offLow = UInt16(UInt8(bitPattern: offset))
            let halfCarry = ((spLow & 0x000F) + (offLow & 0x000F)) > 0x000F
            let fullCarry = (spLow + offLow) > 0x00FF

            setFlags(z: false, n: false, h: halfCarry, c: fullCarry)

            HL = result

            return 3
        case .ldSP_HL:
            SP = HL
            return 2
        case .ld_a16_SP:
            let address = fetch2Bytes()
            mmu.write(UInt8(SP & 0xFF), to: address)
            mmu.write(UInt8((SP >> 8) & 0xFF), to: address &+ 1)
            return 5
        case .jp_a16: // JP a16
            PC = fetch2Bytes()
            return 4
        case .jpNZ_a16:
            let value = fetch2Bytes()
            if !Z {
                PC = value
                return 4
            }
            return 3
        case .jpNC_a16:
            let value = fetch2Bytes()
            if !C {
                PC = value
                return 4
            }
            return 3
        case .jpZ_a16:
            let value = fetch2Bytes()
            if Z {
                PC = value
                return 4
            }
            return 3
        case .jpC_a16:
            let value = fetch2Bytes()
            if C {
                PC = value
                return 4
            }
            return 3
        case .jpHL:
            PC = HL
            return 1
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
        case .daa:
            // Get A and the current flags
            var a = registers[.A]!
            let nFlag = N // did last op subtract?
            var adjust: UInt8 = 0
            var carryOut = C

            if !nFlag {
                // After ADD
                if H || (a & 0x0F) > 9 {
                    adjust |= 0x06
                }
                if C || a > 0x99 {
                    adjust |= 0x60
                    carryOut = true
                }
                a = a &+ adjust
            } else {
                // After SUB
                if H {
                    adjust |= 0x06
                }
                if C {
                    adjust |= 0x60
                }
                a = a &- adjust
            }

            registers[.A] = a

            // Flags: Z set if A==0, N unchanged, H cleared, C updated
            Z = (a == 0)
            H = false
            C = carryOut

            return 1
        case .scf:
            setFlags(z: Z, n: false, h: false, c: true)
            return 1
        case .cpl:
            registers[.A] = ~registers[.A]!
            N = true
            H = true
            return 1
        case .ccf:
            setFlags(z: Z, n: false, h: false, c: !C)
            return 1
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
        case .adcAB:
            let first = registers[.A]!
            let second = registers[.B]!
            let carryIn: UInt8 = C ? 1 : 0

            let sum16 = UInt16(first) + UInt16(second) + UInt16(carryIn)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F) + carryIn) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .adcAC:
            let first = registers[.A]!
            let second = registers[.C]!
            let carryIn: UInt8 = C ? 1 : 0

            let sum16 = UInt16(first) + UInt16(second) + UInt16(carryIn)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F) + carryIn) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .adcAD:
            let first = registers[.A]!
            let second = registers[.D]!
            let carryIn: UInt8 = C ? 1 : 0

            let sum16 = UInt16(first) + UInt16(second) + UInt16(carryIn)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F) + carryIn) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .adcAE:
            let first = registers[.A]!
            let second = registers[.E]!
            let carryIn: UInt8 = C ? 1 : 0

            let sum16 = UInt16(first) + UInt16(second) + UInt16(carryIn)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F) + carryIn) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .adcAH:
            let first = registers[.A]!
            let second = registers[.H]!
            let carryIn: UInt8 = C ? 1 : 0

            let sum16 = UInt16(first) + UInt16(second) + UInt16(carryIn)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F) + carryIn) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .adcAL:
            let first = registers[.A]!
            let second = registers[.L]!
            let carryIn: UInt8 = C ? 1 : 0

            let sum16 = UInt16(first) + UInt16(second) + UInt16(carryIn)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F) + carryIn) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .adc_HL:
            let first = registers[.A]!
            let second = mmu.read(HL)
            let carryIn: UInt8 = C ? 1 : 0

            let sum16 = UInt16(first) + UInt16(second) + UInt16(carryIn)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F) + carryIn) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 2
        case .adcAA:
            let first = registers[.A]!
            let second = registers[.A]!
            let carryIn: UInt8 = C ? 1 : 0

            let sum16 = UInt16(first) + UInt16(second) + UInt16(carryIn)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F) + carryIn) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 1
        case .adc_d8:
            let first = registers[.A]!
            let second = fetchByte()
            let carryIn: UInt8 = C ? 1 : 0

            let sum16 = UInt16(first) + UInt16(second) + UInt16(carryIn)
            let result = UInt8(sum16 & 0xFF)
            registers[.A] = result

            let h = ((first & 0x0F) + (second & 0x0F) + carryIn) > 0x0F
            setFlags(z: result == 0, n: false, h: h, c: sum16 > 0xFF)

            return 2
        case .subB:
            let oldA = registers[.A]!
            let value = registers[.B]!
            let result = oldA &- value
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < (value & 0xF)
            C = oldA < value

            return 1
        case .subC:
            let oldA = registers[.A]!
            let value = registers[.C]!
            let result = oldA &- value
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < (value & 0xF)
            C = oldA < value

            return 1
        case .subD:
            let oldA = registers[.A]!
            let value = registers[.D]!
            let result = oldA &- value
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < (value & 0xF)
            C = oldA < value

            return 1
        case .subE:
            let oldA = registers[.A]!
            let value = registers[.E]!
            let result = oldA &- value
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < (value & 0xF)
            C = oldA < value

            return 1
        case .subH:
            let oldA = registers[.A]!
            let value = registers[.H]!
            let result = oldA &- value
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < (value & 0xF)
            C = oldA < value

            return 1
        case .subL:
            let oldA = registers[.A]!
            let value = registers[.L]!
            let result = oldA &- value
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < (value & 0xF)
            C = oldA < value

            return 1
        case .sub_HL:
            let oldA = registers[.A]!
            let value = mmu.read(HL)
            let result = oldA &- value
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < (value & 0xF)
            C = oldA < value

            return 2
        case .subA:
            let oldA = registers[.A]!
            let value = registers[.A]!
            let result = oldA &- value
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < (value & 0xF)
            C = oldA < value

            return 1
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
        case .sbcAB:
            let oldA = registers[.A]!
            let value = registers[.B]!
            let carryIn: UInt8 = C ? 1 : 0

            let fullSub = UInt16(oldA) &- UInt16(value) &- UInt16(carryIn)
            let result = UInt8(truncatingIfNeeded: fullSub)
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < ((value & 0x0F) &+ carryIn)
            C = UInt16(oldA) < UInt16(value) + UInt16(carryIn)

            return 1
        case .sbcAC:
            let oldA = registers[.A]!
            let value = registers[.C]!
            let carryIn: UInt8 = C ? 1 : 0

            let fullSub = UInt16(oldA) &- UInt16(value) &- UInt16(carryIn)
            let result = UInt8(truncatingIfNeeded: fullSub)
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < ((value & 0x0F) &+ carryIn)
            C = UInt16(oldA) < UInt16(value) + UInt16(carryIn)

            return 1
        case .sbcAD:
            let oldA = registers[.A]!
            let value = registers[.D]!
            let carryIn: UInt8 = C ? 1 : 0

            let fullSub = UInt16(oldA) &- UInt16(value) &- UInt16(carryIn)
            let result = UInt8(truncatingIfNeeded: fullSub)
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < ((value & 0x0F) &+ carryIn)
            C = UInt16(oldA) < UInt16(value) + UInt16(carryIn)

            return 1
        case .sbcAE:
            let oldA = registers[.A]!
            let value = registers[.E]!
            let carryIn: UInt8 = C ? 1 : 0

            let fullSub = UInt16(oldA) &- UInt16(value) &- UInt16(carryIn)
            let result = UInt8(truncatingIfNeeded: fullSub)
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < ((value & 0x0F) &+ carryIn)
            C = UInt16(oldA) < UInt16(value) + UInt16(carryIn)

            return 1
        case .sbcAH:
            let oldA = registers[.A]!
            let value = registers[.H]!
            let carryIn: UInt8 = C ? 1 : 0

            let fullSub = UInt16(oldA) &- UInt16(value) &- UInt16(carryIn)
            let result = UInt8(truncatingIfNeeded: fullSub)
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < ((value & 0x0F) &+ carryIn)
            C = UInt16(oldA) < UInt16(value) + UInt16(carryIn)

            return 1
        case .sbcAL:
            let oldA = registers[.A]!
            let value = registers[.L]!
            let carryIn: UInt8 = C ? 1 : 0

            let fullSub = UInt16(oldA) &- UInt16(value) &- UInt16(carryIn)
            let result = UInt8(truncatingIfNeeded: fullSub)
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < ((value & 0x0F) &+ carryIn)
            C = UInt16(oldA) < UInt16(value) + UInt16(carryIn)

            return 1
        case .sbcA_HL:
            let oldA = registers[.A]!
            let value = mmu[HL]
            let carryIn: UInt8 = C ? 1 : 0

            let fullSub = UInt16(oldA) &- UInt16(value) &- UInt16(carryIn)
            let result = UInt8(truncatingIfNeeded: fullSub)
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < ((value & 0x0F) &+ carryIn)
            C = UInt16(oldA) < UInt16(value) + UInt16(carryIn)

            return 2
        case .sbcAA:
            let oldA = registers[.A]!
            let value = registers[.A]!
            let carryIn: UInt8 = C ? 1 : 0

            let fullSub = UInt16(oldA) &- UInt16(value) &- UInt16(carryIn)
            let result = UInt8(truncatingIfNeeded: fullSub)
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < ((value & 0x0F) &+ carryIn)
            C = UInt16(oldA) < UInt16(value) + UInt16(carryIn)

            return 1
        case .sbcA_d8:
            let oldA = registers[.A]!
            let value = fetchByte()
            let carryIn: UInt8 = C ? 1 : 0

            let fullSub = UInt16(oldA) &- UInt16(value) &- UInt16(carryIn)
            let result = UInt8(truncatingIfNeeded: fullSub)
            registers[.A] = result

            Z = result == 0
            N = true
            H = (oldA & 0xF) < ((value & 0x0F) &+ carryIn)
            C = UInt16(oldA) < UInt16(value) + UInt16(carryIn)

            return 2
        case .andB:
            registers[.A]! &= registers[.B]!
            setFlags(z: registers[.A] == 0, n: false, h: true, c: false)
            return 1
        case .andC:
            registers[.A]! &= registers[.C]!
            setFlags(z: registers[.A] == 0, n: false, h: true, c: false)
            return 1
        case .andD:
            registers[.A]! &= registers[.D]!
            setFlags(z: registers[.A] == 0, n: false, h: true, c: false)
            return 1
        case .andE:
            registers[.A]! &= registers[.E]!
            setFlags(z: registers[.A] == 0, n: false, h: true, c: false)
            return 1
        case .andH:
            registers[.A]! &= registers[.H]!
            setFlags(z: registers[.A] == 0, n: false, h: true, c: false)
            return 1
        case .andL:
            registers[.A]! &= registers[.L]!
            setFlags(z: registers[.A] == 0, n: false, h: true, c: false)
            return 1
        case .and_HL:
            registers[.A]! &= mmu.read(HL)
            setFlags(z: registers[.A] == 0, n: false, h: true, c: false)
            return 2
        case .andA:
            registers[.A]! &= registers[.A]!
            setFlags(z: registers[.A] == 0, n: false, h: true, c: false)
            return 1
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
        case .or_HL:
            let result = registers[.A]! | mmu.read(HL)
            registers[.A] = result
            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 2
        case .orA:
            let result = registers[.A]!
//            registers[.A] = result // It's the same
            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 1
        case .or_d8:
            let result = registers[.A]! | fetchByte()
            registers[.A] = result
            let zFlag: UInt8 = 1 << 7
            registers[.F] = (result == 0) ? zFlag : 0
            return 2
        case .cpB:
            let a = registers[.A]!
            let value = registers[.B]!
            let result = a &- value

            let halfBorrow = (a & 0x0F) < (value & 0x0F)
            let fullBorrow = a < value
            setFlags(z: result == 0, n: true, h: halfBorrow, c: fullBorrow)

            return 1
        case .cpC:
            let a = registers[.A]!
            let value = registers[.C]!
            let result = a &- value

            let halfBorrow = (a & 0x0F) < (value & 0x0F)
            let fullBorrow = a < value
            setFlags(z: result == 0, n: true, h: halfBorrow, c: fullBorrow)

            return 1
        case .cpD:
            let a = registers[.A]!
            let value = registers[.D]!
            let result = a &- value

            let halfBorrow = (a & 0x0F) < (value & 0x0F)
            let fullBorrow = a < value
            setFlags(z: result == 0, n: true, h: halfBorrow, c: fullBorrow)

            return 1
        case .cpE:
            let a = registers[.A]!
            let value = registers[.E]!
            let result = a &- value

            let halfBorrow = (a & 0x0F) < (value & 0x0F)
            let fullBorrow = a < value
            setFlags(z: result == 0, n: true, h: halfBorrow, c: fullBorrow)

            return 1
        case .cpH:
            let a = registers[.A]!
            let value = registers[.H]!
            let result = a &- value

            let halfBorrow = (a & 0x0F) < (value & 0x0F)
            let fullBorrow = a < value
            setFlags(z: result == 0, n: true, h: halfBorrow, c: fullBorrow)

            return 1
        case .cpL:
            let a = registers[.A]!
            let value = registers[.L]!
            let result = a &- value

            let halfBorrow = (a & 0x0F) < (value & 0x0F)
            let fullBorrow = a < value
            setFlags(z: result == 0, n: true, h: halfBorrow, c: fullBorrow)

            return 1
        case .cp_HL:
            let a = registers[.A]!
            let value = mmu[HL]
            let result = a &- value

            let halfBorrow = (a & 0x0F) < (value & 0x0F)
            let fullBorrow = a < value
            setFlags(z: result == 0, n: true, h: halfBorrow, c: fullBorrow)

            return 2
        case .cpA:
            let a = registers[.A]!
            let value = registers[.A]!
            let result = a &- value

            let halfBorrow = (a & 0x0F) < (value & 0x0F)
            let fullBorrow = a < value
            setFlags(z: result == 0, n: true, h: halfBorrow, c: fullBorrow)

            return 1
        case .rst0:
            push16(PC)
            PC = 0x0000
            return 4
        case .rst1:
            push16(PC)
            PC = 0x0008
            return 4
        case .rst2:
            push16(PC)
            PC = 0x0010
            return 4
        case .rst3:
            push16(PC)
            PC = 0x0018
            return 4
        case .rst4:
            push16(PC)
            PC = 0x0020
            return 4
        case .rst5:
            push16(PC)
            PC = 0x0028
            return 4
        case .rst6:
            push16(PC)
            PC = 0x0030
            return 4
        case .rst7:
            push16(PC)
            PC = 0x0038
            return 4
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
            push16(PC)

            // Jump to address
            PC = address
            return 6
        case .callZ_a16:
            let address = fetch2Bytes()
            if Z {
                push16(PC)

                // Jump to address
                PC = address
                return 6
            }

            return 3
        case .callNZ_a16:
            let address = fetch2Bytes()
            if !Z {
                push16(PC)

                // Jump to address
                PC = address
                return 6
            }

            return 3
        case .callC_a16:
            let address = fetch2Bytes()
            if C {
                push16(PC)

                // Jump to address
                PC = address
                return 6
            }

            return 3
        case .callNC_a16:
            let address = fetch2Bytes()
            if !C {
                push16(PC)

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
            push16(AF)
            return 4
        case .pushBC:
            push16(BC)
            return 4
        case .pushDE:
            push16(DE)
            return 4
        case .pushHL:
            push16(HL)
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
        case .addHL_BC:
            let full = UInt32(HL) + UInt32(BC)
            let half = ((UInt32(HL) & 0x0FFF) + (UInt32(BC) & 0x0FFF)) > 0x0FFF
            let carry = full > 0xFFFF

            HL = UInt16(truncatingIfNeeded: full)
            setFlags(z: Z, n: false, h: half, c: carry)
            return 2
        case .addHL_DE:
            let full = UInt32(HL) + UInt32(DE)
            let half = ((UInt32(HL) & 0x0FFF) + (UInt32(DE) & 0x0FFF)) > 0x0FFF
            let carry = full > 0xFFFF

            HL = UInt16(truncatingIfNeeded: full)
            setFlags(z: Z, n: false, h: half, c: carry)
            return 2
        case .addHL_HL:
            let full = UInt32(HL) + UInt32(HL)
            let half = ((UInt32(HL) & 0x0FFF) + (UInt32(HL) & 0x0FFF)) > 0x0FFF
            let carry = full > 0xFFFF

            HL = UInt16(truncatingIfNeeded: full)
            setFlags(z: Z, n: false, h: half, c: carry)
            return 2
        case .addHL_SP:
            let full = UInt32(HL) + UInt32(SP)
            let half = ((UInt32(HL) & 0x0FFF) + (UInt32(SP) & 0x0FFF)) > 0x0FFF
            let carry = full > 0xFFFF

            HL = UInt16(truncatingIfNeeded: full)
            setFlags(z: Z, n: false, h: half, c: carry)
            return 2
        case .addSP_s8:
            // Read signed 8-bit displacement
            let raw = fetchByte() // PC was incremented once for opcode fetch, now again for displacement
            let offset = Int8(bitPattern: raw) // Interpret as signed

            let delta = UInt16(bitPattern: Int16(offset))

            let halfCarry = ((SP & 0x0F) + (delta & 0x0F)) > 0x0F
            let carry = ((SP & 0xFF) + (delta & 0xFF)) > 0xFF

            SP &+= delta
            setFlags(z: false, n: false, h: halfCarry, c: carry)

            return 4
        case .decBC:
            BC &-= 1
            return 2
        case .decDE:
            DE &-= 1
            return 2
        case .decHL:
            HL &-= 1
            return 2
        case .decSP:
            SP &-= 1
            return 2
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
        case .inc_HL:
            let old = mmu.read(HL)
            let value = old &+ 1
            mmu.write(value, to: HL)
            Z = value == 0
            N = false
            H = (old & 0x0F) == 0x0F
            return 2
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
        case .dec_HL:
            let old = mmu.read(HL)
            let value = old &- 1
            mmu.write(value, to: HL)
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

            return 2
        case .rlca:
            let old = registers[.A]!
            let msb = ((old >> 7) & 0x01) != 0
            registers[.A] = (old << 1) | (msb ? 1 : 0)

            setFlags(z: false, n: false, h: false, c: msb)
            return 1
        case .rla:
            let old = registers[.A]!
            registers[.A] = (old << 1) | (C ? 1 : 0)

            let msb = ((old >> 7) & 0x01) != 0
            setFlags(z: false, n: false, h: false, c: msb)
            return 1
        case .rrca:
            let old = registers[.A]!
            let lsb = (old & 0x01) != 0
            registers[.A] = (old >> 1) | (lsb ? 0x80 : 0x00)

            setFlags(z: false, n: false, h: false, c: lsb)
            return 1
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
            Logger.log("CPU stopped")
            return 1
        case .halt:
            halted = true
            return 1
        case .cb:
            return executeNextCBInstruction()
        case .none:
            Logger.log("Unknown opcode: \(String(format: "%02X", opcode)) at PC: \(String(format: "%04X", PC - 1))")
            halted = true
            return 1
        }
    }

    func executeNextCBInstruction() -> Int {
        let opcode = fetchByte()
        logState(opcode: opcode)

        switch CBOpcode(rawValue: opcode) {
        case .rlcB:
            let old = registers[.B]!
            let lsb = (old >> 7) & 0x01
            let result = (old << 1) | lsb
            registers[.B] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rlcC:
            let old = registers[.C]!
            let lsb = (old >> 7) & 0x01
            let result = (old << 1) | lsb
            registers[.C] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rlcD:
            let old = registers[.D]!
            let lsb = (old >> 7) & 0x01
            let result = (old << 1) | lsb
            registers[.D] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rlcE:
            let old = registers[.E]!
            let lsb = (old >> 7) & 0x01
            let result = (old << 1) | lsb
            registers[.E] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rlcH:
            let old = registers[.H]!
            let lsb = (old >> 7) & 0x01
            let result = (old << 1) | lsb
            registers[.H] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rlcL:
            let old = registers[.L]!
            let lsb = (old >> 7) & 0x01
            let result = (old << 1) | lsb
            registers[.L] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rlc_HL:
            let old = mmu[HL]
            let lsb = (old >> 7) & 0x01
            let result = (old << 1) | lsb
            mmu[HL] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 4
        case .rlcA:
            let old = registers[.A]!
            let lsb = (old >> 7) & 0x01
            let result = (old << 1) | lsb
            registers[.A] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rrcB:
            let old = registers[.B]!
            let lsb = old & 0x01
            let result = (old >> 1) | (lsb << 7)
            registers[.B] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rrcC:
            let old = registers[.C]!
            let lsb = old & 0x01
            let result = (old >> 1) | (lsb << 7)
            registers[.C] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rrcD:
            let old = registers[.D]!
            let lsb = old & 0x01
            let result = (old >> 1) | (lsb << 7)
            registers[.D] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rrcE:
            let old = registers[.E]!
            let lsb = old & 0x01
            let result = (old >> 1) | (lsb << 7)
            registers[.E] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rrcH:
            let old = registers[.H]!
            let lsb = old & 0x01
            let result = (old >> 1) | (lsb << 7)
            registers[.H] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rrcL:
            let old = registers[.L]!
            let lsb = old & 0x01
            let result = (old >> 1) | (lsb << 7)
            registers[.L] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rrc_HL:
            let old = mmu[HL]
            let lsb = old & 0x01
            let result = (old >> 1) | (lsb << 7)
            mmu[HL] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 4
        case .rrcA:
            let old = registers[.A]!
            let lsb = old & 0x01
            let result = (old >> 1) | (lsb << 7)
            registers[.A] = result

            setFlags(z: result == 0, n: false, h: false, c: lsb == 1)
            return 2
        case .rlB:
            let old = registers[.B]!
            let result = (old << 1) | (C ? 0x01 : 0x00)
            registers[.B] = result

            let msb = ((old >> 7) & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: msb)
            return 2
        case .rlC:
            let old = registers[.C]!
            let result = (old << 1) | (C ? 0x01 : 0x00)
            registers[.C] = result

            let msb = ((old >> 7) & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: msb)
            return 2
        case .rlD:
            let old = registers[.D]!
            let result = (old << 1) | (C ? 0x01 : 0x00)
            registers[.D] = result

            let msb = ((old >> 7) & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: msb)
            return 2
        case .rlE:
            let old = registers[.E]!
            let result = (old << 1) | (C ? 0x01 : 0x00)
            registers[.E] = result

            let msb = ((old >> 7) & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: msb)
            return 2
        case .rlH:
            let old = registers[.H]!
            let result = (old << 1) | (C ? 0x01 : 0x00)
            registers[.H] = result

            let msb = ((old >> 7) & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: msb)
            return 2
        case .rlL:
            let old = registers[.L]!
            let result = (old << 1) | (C ? 0x01 : 0x00)
            registers[.L] = result

            let msb = ((old >> 7) & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: msb)
            return 2
        case .rl_HL:
            let old = mmu[HL]
            let result = (old << 1) | (C ? 0x01 : 0x00)
            mmu[HL] = result

            let msb = ((old >> 7) & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: msb)
            return 4
        case .rlA:
            let old = registers[.A]!
            let result = (old << 1) | (C ? 0x01 : 0x00)
            registers[.A] = result

            let msb = ((old >> 7) & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: msb)
            return 2
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
        case .rr_HL:
            let old = mmu[HL]
            let result = (old >> 1) | (C ? 0x80 : 0x00)
            mmu[HL] = result

            let lsb = (old & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: lsb)
            return 4
        case .rrA:
            let old = registers[.A]!
            let result = (old >> 1) | (C ? 0x80 : 0x00)
            registers[.A] = result

            let lsb = (old & 0x01) != 0
            setFlags(z: result == 0, n: false, h: false, c: lsb)
            return 2
        case .slaB:
            let value = registers[.B]!
            let CY = value >> 7 & 1 == 1
            let result = value << 1
            registers[.B] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .slaC:
            let value = registers[.C]!
            let CY = value >> 7 & 1 == 1
            let result = value << 1
            registers[.C] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .slaD:
            let value = registers[.D]!
            let CY = value >> 7 & 1 == 1
            let result = value << 1
            registers[.D] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .slaE:
            let value = registers[.E]!
            let CY = value >> 7 & 1 == 1
            let result = value << 1
            registers[.E] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .slaH:
            let value = registers[.H]!
            let CY = value >> 7 & 1 == 1
            let result = value << 1
            registers[.H] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .slaL:
            let value = registers[.L]!
            let CY = value >> 7 & 1 == 1
            let result = value << 1
            registers[.L] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .sla_HL:
            let value = mmu[HL]
            let CY = value >> 7 & 1 == 1
            let result = value << 1
            mmu[HL] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 4
        case .slaA:
            let value = registers[.A]!
            let CY = value >> 7 & 1 == 1
            let result = value << 1
            registers[.A] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .sraB:
            let old = registers[.B]!
            let carry = old & 0x01 == 1
            let result = (old >> 1) | (old & 0x80)
            registers[.B] = result

            setFlags(z: result == 0, n: false, h: false, c: carry)
            return 2
        case .sraC:
            let old = registers[.C]!
            let carry = old & 0x01 == 1
            let result = (old >> 1) | (old & 0x80)
            registers[.C] = result

            setFlags(z: result == 0, n: false, h: false, c: carry)
            return 2
        case .sraD:
            let old = registers[.D]!
            let carry = old & 0x01 == 1
            let result = (old >> 1) | (old & 0x80)
            registers[.D] = result

            setFlags(z: result == 0, n: false, h: false, c: carry)
            return 2
        case .sraE:
            let old = registers[.E]!
            let carry = old & 0x01 == 1
            let result = (old >> 1) | (old & 0x80)
            registers[.E] = result

            setFlags(z: result == 0, n: false, h: false, c: carry)
            return 2
        case .sraH:
            let old = registers[.H]!
            let carry = old & 0x01 == 1
            let result = (old >> 1) | (old & 0x80)
            registers[.H] = result

            setFlags(z: result == 0, n: false, h: false, c: carry)
            return 2
        case .sraL:
            let old = registers[.L]!
            let carry = old & 0x01 == 1
            let result = (old >> 1) | (old & 0x80)
            registers[.L] = result

            setFlags(z: result == 0, n: false, h: false, c: carry)
            return 2
        case .sra_HL:
            let old = mmu[HL]
            let carry = old & 0x01 == 1
            let result = (old >> 1) | (old & 0x80)
            mmu[HL] = result

            setFlags(z: result == 0, n: false, h: false, c: carry)
            return 4
        case .sraA:
            let old = registers[.A]!
            let carry = old & 0x01 == 1
            let result = (old >> 1) | (old & 0x80)
            registers[.A] = result

            setFlags(z: result == 0, n: false, h: false, c: carry)
            return 2
        case .swapB:
            let value = registers[.B]!
            let result = ((value & 0x0F) << 4) | ((value & 0xF0) >> 4)
            registers[.B] = result
            setFlags(z: result == 0, n: false, h: false, c: false)
            return 2
        case .swapC:
            let value = registers[.C]!
            let result = ((value & 0x0F) << 4) | ((value & 0xF0) >> 4)
            registers[.C] = result
            setFlags(z: result == 0, n: false, h: false, c: false)
            return 2
        case .swapD:
            let value = registers[.D]!
            let result = ((value & 0x0F) << 4) | ((value & 0xF0) >> 4)
            registers[.D] = result
            setFlags(z: result == 0, n: false, h: false, c: false)
            return 2
        case .swapE:
            let value = registers[.E]!
            let result = ((value & 0x0F) << 4) | ((value & 0xF0) >> 4)
            registers[.E] = result
            setFlags(z: result == 0, n: false, h: false, c: false)
            return 2
        case .swapH:
            let value = registers[.H]!
            let result = ((value & 0x0F) << 4) | ((value & 0xF0) >> 4)
            registers[.H] = result
            setFlags(z: result == 0, n: false, h: false, c: false)
            return 2
        case .swapL:
            let value = registers[.L]!
            let result = ((value & 0x0F) << 4) | ((value & 0xF0) >> 4)
            registers[.L] = result
            setFlags(z: result == 0, n: false, h: false, c: false)
            return 2
        case .swap_HL:
            let value = mmu[HL]
            let result = ((value & 0x0F) << 4) | ((value & 0xF0) >> 4)
            mmu[HL] = result
            setFlags(z: result == 0, n: false, h: false, c: false)
            return 4
        case .swapA:
            let value = registers[.A]!
            let result = ((value & 0x0F) << 4) | ((value & 0xF0) >> 4)
            registers[.A] = result
            setFlags(z: result == 0, n: false, h: false, c: false)
            return 2
        case .srlB:
            let CY = registers[.B]! & 1 == 1
            let result = registers[.B]! >> 1
            registers[.B] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .srlC:
            let CY = registers[.C]! & 1 == 1
            let result = registers[.C]! >> 1
            registers[.C] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .srlD:
            let CY = registers[.D]! & 1 == 1
            let result = registers[.D]! >> 1
            registers[.D] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .srlE:
            let CY = registers[.E]! & 1 == 1
            let result = registers[.E]! >> 1
            registers[.E] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .srlH:
            let CY = registers[.H]! & 1 == 1
            let result = registers[.H]! >> 1
            registers[.H] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .srlL:
            let CY = registers[.L]! & 1 == 1
            let result = registers[.L]! >> 1
            registers[.L] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 2
        case .srl_HL:
            let value = mmu[HL]
            let CY = value & 1 == 1
            let result = value >> 1
            mmu[HL] = result
            setFlags(z: result == 0, n: false, h: false, c: CY)
            return 4
        case .srlA:
            let CY = registers[.A]! & 1 == 1
            let result = registers[.A]! >> 1
            registers[.A] = result
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
        case .res0B:
            return resetBit(0, in: &registers[.B]!)
        case .res0C:
            return resetBit(0, in: &registers[.C]!)
        case .res0D:
            return resetBit(0, in: &registers[.D]!)
        case .res0E:
            return resetBit(0, in: &registers[.E]!)
        case .res0H:
            return resetBit(0, in: &registers[.H]!)
        case .res0L:
            return resetBit(0, in: &registers[.L]!)
        case .res0_HL:
            return resetBit(0, in: &mmu[HL]) + 2
        case .res0A:
            return resetBit(0, in: &registers[.A]!)
        case .res1B:
            return resetBit(1, in: &registers[.B]!)
        case .res1C:
            return resetBit(1, in: &registers[.C]!)
        case .res1D:
            return resetBit(1, in: &registers[.D]!)
        case .res1E:
            return resetBit(1, in: &registers[.E]!)
        case .res1H:
            return resetBit(1, in: &registers[.H]!)
        case .res1L:
            return resetBit(1, in: &registers[.L]!)
        case .res1_HL:
            return resetBit(1, in: &mmu[HL]) + 2
        case .res1A:
            return resetBit(1, in: &registers[.A]!)
        case .res2B:
            return resetBit(2, in: &registers[.B]!)
        case .res2C:
            return resetBit(2, in: &registers[.C]!)
        case .res2D:
            return resetBit(2, in: &registers[.D]!)
        case .res2E:
            return resetBit(2, in: &registers[.E]!)
        case .res2H:
            return resetBit(2, in: &registers[.H]!)
        case .res2L:
            return resetBit(2, in: &registers[.L]!)
        case .res2_HL:
            return resetBit(2, in: &mmu[HL]) + 2
        case .res2A:
            return resetBit(2, in: &registers[.A]!)
        case .res3B:
            return resetBit(3, in: &registers[.B]!)
        case .res3C:
            return resetBit(3, in: &registers[.C]!)
        case .res3D:
            return resetBit(3, in: &registers[.D]!)
        case .res3E:
            return resetBit(3, in: &registers[.E]!)
        case .res3H:
            return resetBit(3, in: &registers[.H]!)
        case .res3L:
            return resetBit(3, in: &registers[.L]!)
        case .res3_HL:
            return resetBit(3, in: &mmu[HL]) + 2
        case .res3A:
            return resetBit(3, in: &registers[.A]!)
        case .res4B:
            return resetBit(4, in: &registers[.B]!)
        case .res4C:
            return resetBit(4, in: &registers[.C]!)
        case .res4D:
            return resetBit(4, in: &registers[.D]!)
        case .res4E:
            return resetBit(4, in: &registers[.E]!)
        case .res4H:
            return resetBit(4, in: &registers[.H]!)
        case .res4L:
            return resetBit(4, in: &registers[.L]!)
        case .res4_HL:
            return resetBit(4, in: &mmu[HL]) + 2
        case .res4A:
            return resetBit(4, in: &registers[.A]!)
        case .res5B:
            return resetBit(5, in: &registers[.B]!)
        case .res5C:
            return resetBit(5, in: &registers[.C]!)
        case .res5D:
            return resetBit(5, in: &registers[.D]!)
        case .res5E:
            return resetBit(5, in: &registers[.E]!)
        case .res5H:
            return resetBit(5, in: &registers[.H]!)
        case .res5L:
            return resetBit(5, in: &registers[.L]!)
        case .res5_HL:
            return resetBit(5, in: &mmu[HL]) + 2
        case .res5A:
            return resetBit(5, in: &registers[.A]!)
        case .res6B:
            return resetBit(6, in: &registers[.B]!)
        case .res6C:
            return resetBit(6, in: &registers[.C]!)
        case .res6D:
            return resetBit(6, in: &registers[.D]!)
        case .res6E:
            return resetBit(6, in: &registers[.E]!)
        case .res6H:
            return resetBit(6, in: &registers[.H]!)
        case .res6L:
            return resetBit(6, in: &registers[.L]!)
        case .res6_HL:
            return resetBit(6, in: &mmu[HL]) + 2
        case .res6A:
            return resetBit(6, in: &registers[.A]!)
        case .res7B:
            return resetBit(7, in: &registers[.B]!)
        case .res7C:
            return resetBit(7, in: &registers[.C]!)
        case .res7D:
            return resetBit(7, in: &registers[.D]!)
        case .res7E:
            return resetBit(7, in: &registers[.E]!)
        case .res7H:
            return resetBit(7, in: &registers[.H]!)
        case .res7L:
            return resetBit(7, in: &registers[.L]!)
        case .res7_HL:
            return resetBit(7, in: &mmu[HL]) + 2
        case .res7A:
            return resetBit(7, in: &registers[.A]!)
        case .set0B:
            return setBit(0, in: &registers[.B]!)
        case .set0C:
            return setBit(0, in: &registers[.C]!)
        case .set0D:
            return setBit(0, in: &registers[.D]!)
        case .set0E:
            return setBit(0, in: &registers[.E]!)
        case .set0H:
            return setBit(0, in: &registers[.H]!)
        case .set0L:
            return setBit(0, in: &registers[.L]!)
        case .set0_HL:
            return setBit(0, in: &mmu[HL]) + 2
        case .set0A:
            return setBit(0, in: &registers[.A]!)
        case .set1B:
            return setBit(1, in: &registers[.B]!)
        case .set1C:
            return setBit(1, in: &registers[.C]!)
        case .set1D:
            return setBit(1, in: &registers[.D]!)
        case .set1E:
            return setBit(1, in: &registers[.E]!)
        case .set1H:
            return setBit(1, in: &registers[.H]!)
        case .set1L:
            return setBit(1, in: &registers[.L]!)
        case .set1_HL:
            return setBit(1, in: &mmu[HL]) + 2
        case .set1A:
            return setBit(1, in: &registers[.A]!)
        case .set2B:
            return setBit(2, in: &registers[.B]!)
        case .set2C:
            return setBit(2, in: &registers[.C]!)
        case .set2D:
            return setBit(2, in: &registers[.D]!)
        case .set2E:
            return setBit(2, in: &registers[.E]!)
        case .set2H:
            return setBit(2, in: &registers[.H]!)
        case .set2L:
            return setBit(2, in: &registers[.L]!)
        case .set2_HL:
            return setBit(2, in: &mmu[HL]) + 2
        case .set2A:
            return setBit(2, in: &registers[.A]!)
        case .set3B:
            return setBit(3, in: &registers[.B]!)
        case .set3C:
            return setBit(3, in: &registers[.C]!)
        case .set3D:
            return setBit(3, in: &registers[.D]!)
        case .set3E:
            return setBit(3, in: &registers[.E]!)
        case .set3H:
            return setBit(3, in: &registers[.H]!)
        case .set3L:
            return setBit(3, in: &registers[.L]!)
        case .set3_HL:
            return setBit(3, in: &mmu[HL]) + 2
        case .set3A:
            return setBit(3, in: &registers[.A]!)
        case .set4B:
            return setBit(4, in: &registers[.B]!)
        case .set4C:
            return setBit(4, in: &registers[.C]!)
        case .set4D:
            return setBit(4, in: &registers[.D]!)
        case .set4E:
            return setBit(4, in: &registers[.E]!)
        case .set4H:
            return setBit(4, in: &registers[.H]!)
        case .set4L:
            return setBit(4, in: &registers[.L]!)
        case .set4_HL:
            return setBit(4, in: &mmu[HL]) + 2
        case .set4A:
            return setBit(4, in: &registers[.A]!)
        case .set5B:
            return setBit(5, in: &registers[.B]!)
        case .set5C:
            return setBit(5, in: &registers[.C]!)
        case .set5D:
            return setBit(5, in: &registers[.D]!)
        case .set5E:
            return setBit(5, in: &registers[.E]!)
        case .set5H:
            return setBit(5, in: &registers[.H]!)
        case .set5L:
            return setBit(5, in: &registers[.L]!)
        case .set5_HL:
            return setBit(5, in: &mmu[HL]) + 2
        case .set5A:
            return setBit(5, in: &registers[.A]!)
        case .set6B:
            return setBit(6, in: &registers[.B]!)
        case .set6C:
            return setBit(6, in: &registers[.C]!)
        case .set6D:
            return setBit(6, in: &registers[.D]!)
        case .set6E:
            return setBit(6, in: &registers[.E]!)
        case .set6H:
            return setBit(6, in: &registers[.H]!)
        case .set6L:
            return setBit(6, in: &registers[.L]!)
        case .set6_HL:
            return setBit(6, in: &mmu[HL]) + 2
        case .set6A:
            return setBit(6, in: &registers[.A]!)
        case .set7B:
            return setBit(7, in: &registers[.B]!)
        case .set7C:
            return setBit(7, in: &registers[.C]!)
        case .set7D:
            return setBit(7, in: &registers[.D]!)
        case .set7E:
            return setBit(7, in: &registers[.E]!)
        case .set7H:
            return setBit(7, in: &registers[.H]!)
        case .set7L:
            return setBit(7, in: &registers[.L]!)
        case .set7_HL:
            return setBit(7, in: &mmu[HL]) + 2
        case .set7A:
            return setBit(7, in: &registers[.A]!)
        case .none:
            Logger.log("Unknown CB opcode: \(String(format: "%02X", opcode)) at PC: \(String(format: "%04X", PC - 1))")
            halted = true
            return 1
        }
    }

    func testBit(_ b: Int, in value: UInt8) -> Int {
        let bit = (value >> b) & 1 == 1
        setFlags(z: !bit, n: false, h: true, c: C)
        return 2
    }

    func resetBit(_ b: Int, in memory: inout UInt8) -> Int {
        memory = memory & ~(1 << b)
        return 2
    }

    func setBit(_ b: Int, in memory: inout UInt8) -> Int {
        memory = memory | (1 << b)
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

    // Interrupt vectors (in bytes)
    private let interruptVectors: [UInt16] = [
        0x40, // V-Blank
        0x48, // LCD STAT
        0x50, // Timer
        0x58, // Serial
        0x60 // Joypad
    ]
}

// MARK: - Helpers
private extension CPU {
    // MARK: - Registers
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
            registers[.C] = UInt8(newValue & 0xFF)
        }
    }

    var DE: UInt16 {
        get { (UInt16(registers[.D]!) << 8) | UInt16(registers[.E]!) }
        set {
            registers[.D] = UInt8((newValue >> 8) & 0xFF)
            registers[.E] = UInt8(newValue & 0xFF)
        }
    }

    var HL: UInt16 {
        get { (UInt16(registers[.H]!) << 8) | UInt16(registers[.L]!) }
        set {
            registers[.H] = UInt8((newValue >> 8) & 0xFF)
            registers[.L] = UInt8(newValue & 0xFF)
        }
    }

    // MARK: - Regiter Flags
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

    // MARK: - Memory
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

    // MARK: - Stack
    func pop16() -> UInt16 {
        let low = mmu.read(SP); SP &+= 1
        let high = mmu.read(SP); SP &+= 1
        return (UInt16(high) << 8) | UInt16(low)
    }

    func push16(_ data: UInt16) {
        SP &-= 1
        mmu.write(UInt8((data >> 8) & 0xFF), to: SP) // High byte
        SP &-= 1
        mmu.write(UInt8(data & 0xFF), to: SP) // Low byte
    }

    // MARK: - Utils
    func logState(opcode: UInt8) {
        return

        let flags = registers[.F]!
        func fbit(_ bit: Int) -> Int { Int((flags >> bit) & 1) }

        Logger.log(String(
            format: "PC:%04X  OP:%02X  AF:%02X%02X  BC:%02X%02X  DE:%02X%02X  HL:%02X%02X  SP:%04X Z:%d N:%d H:%d SP:%d IME:\(interruptMasterEnable)",
            PC - 1, opcode,
            registers[.A]!, flags,
            registers[.B]!, registers[.C]!,
            registers[.D]!, registers[.E]!,
            registers[.H]!, registers[.L]!,
            SP,
            fbit(7), fbit(6), fbit(5), fbit(4)
        ), ignoreXcodeLog: true)
    }
}

extension CPU {
    // MARK: - Step
    func step() -> Int {
        var stepCount = 0
        stepCount += executeNextInstruction()
        return stepCount * 4
    }

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

extension CPU {
    /// Checks IF & IE & IME, and if any interrupt is pending:
    /// 1. disables IME
    /// 2. clears that IF bit
    /// 3. pushes PC onto the stack
    /// 4. jumps to the appropriate vector
    func serviceInterruptsIfNeeded() -> Int {
        // 0) wake from HALT on *any* pending request
        let ifReg = mmu.read(0xFF0F) // Interrupt Flag

        if halted, ifReg != 0 {
            halted = false
        }

        // 1) only if interrupts are enabled
        guard interruptMasterEnable else { return 0 }

        // 2) read the two registers
        let ieReg = mmu.read(0xFFFF) // Interrupt Enable

        // 3) find any bit that is set in both IF and IE
        let pending = ifReg & ieReg
        guard pending != 0 else { return 0 }

        // 4) from highest priority (bit0) to lowest (bit4), find the first one
        let bit = UInt8(pending.trailingZeroBitCount) // index of first set bit
        let vector = interruptVectors[Int(bit)]

        // 5) disable further interrupts until EI is executed again
        interruptMasterEnable = false

        // 6) clear the flag in IF
        let newIf = ifReg & ~(1 << bit)
        mmu.write(newIf, to: 0xFF0F)

        // 7) push the current PC to the stack
        push16(UInt16(PC & 0xFFFF))

        // 8) jump to the interrupt handler
        PC = vector

        // 9) the interrupt takes 5 machine‐cycles (20 T-cycles)
        return 20
    }
}

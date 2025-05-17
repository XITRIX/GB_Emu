//
//  APU.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 17.05.2025.
//

class APU {
    enum SeqStep: Int { case s0, s1, s2, s3, s4, s5, s6, s7 }

    private let mmu: MMU
    private var sequencerClock: Int = 0 // accumulates T-cycles
    private var seqStep: SeqStep = .s0

    // channel objects:
    private let ch1: APUChannelProtocol
    private let ch2: APUChannelProtocol
    private let ch3: APUChannelProtocol
    private let ch4: APUChannelProtocol

    private var masterLeft: UInt8 = 0
    private var masterRight: UInt8 = 0
    private var chanEnable: UInt8 = 0

    init(mmu: MMU) {
        self.mmu = mmu
        ch1 = Square1(mmu: mmu)
        ch2 = Square2(mmu: mmu)
        ch3 = Wave(mmu: mmu)
        ch4 = Noise(mmu: mmu)
    }

    /// Call from your main loop each instruction:
    func step(cycles: Int) {
        sequencerClock += cycles
        // 8192 T-cycles per frame-sequencer tick (512 Hz)
        while sequencerClock >= 8192 {
            sequencerClock -= 8192
            tickSequencer()
        }

        // advance each channel’s sample generator by `cycles`,
        // fill an audio buffer, etc.
        ch1.step(cycles: cycles)
        ch2.step(cycles: cycles)
        ch3.step(cycles: cycles)
        ch4.step(cycles: cycles)
    }

    private func tickSequencer() {
        // advance to next step 0…7
        seqStep = SeqStep(rawValue: (seqStep.rawValue + 1) & 7)!

        // 0,2,4,6 → clock length counters
        if seqStep.rawValue % 2 == 0 {
            ch1.clockLength()
            ch2.clockLength()
            ch3.clockLength()
            ch4.clockLength()
        }
        // 2,6 → clock sweep
        if seqStep == .s2 || seqStep == .s6 {
            ch1.clockSweep()
        }
        // 7 → clock volume envelope
        if seqStep == .s7 {
            ch1.clockEnvelope()
            ch2.clockEnvelope()
            ch4.clockEnvelope()
        }

        masterLeft = mmu.read(0xFF24) // NR50
        masterRight = mmu.read(0xFF24) >> 4
        chanEnable = mmu.read(0xFF25) // NR51

        print("masterLeft: \(masterLeft), masterRight: \(masterRight), chanEnable: \(chanEnable)")
    }

    /// Returns a stereo pair of signed 16-bit samples
    func mixStereoSample() -> (left: Int16, right: Int16) {
        let s1 = ch1.currentSample()
        let s2 = ch2.currentSample()
        let s3 = ch3.currentSample()
        let s4 = ch4.currentSample()

        // NR52._7 (“all sound on”) must also be checked, but let’s assume it is.
        // NR51 bits 0–3 = ch1–4 to left, bits 4–7 = ch1–4 to right.
        // NR50 bits 0–2 = left vol (0–7), bits 4–6 = right vol (0–7).

        // Build the left/right sums only for enabled channels:
        var leftSum = 0, rightSum = 0
        if (chanEnable & 0b0000_0001) != 0 { leftSum += Int(s1) }
        if (chanEnable & 0b0000_0010) != 0 { leftSum += Int(s2) }
        if (chanEnable & 0b0000_0100) != 0 { leftSum += Int(s3) }
        if (chanEnable & 0b0000_1000) != 0 { leftSum += Int(s4) }

        if (chanEnable & 0b0001_0000) != 0 { rightSum += Int(s1) }
        if (chanEnable & 0b0010_0000) != 0 { rightSum += Int(s2) }
        if (chanEnable & 0b0100_0000) != 0 { rightSum += Int(s3) }
        if (chanEnable & 0b1000_0000) != 0 { rightSum += Int(s4) }

        // Now apply the two 3-bit master volumes (0–7 → scale 0.0–1.0)
        let lv = Float(masterLeft & 0b0000_0111) / 7.0
        let rv = Float(masterRight & 0b0000_0111) / 7.0

        let left = Int16(clamping: Int(Float(leftSum) * lv))
        let right = Int16(clamping: Int(Float(rightSum) * rv))
        return (left, right)
    }
}

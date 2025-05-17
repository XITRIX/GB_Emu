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
    private let ch2: APUChannelProtocol!
    private let ch3: APUChannelProtocol!
    private let ch4: APUChannelProtocol!

    init(mmu: MMU) {
        self.mmu = mmu
        ch1 = Square1(mmu: mmu)
        ch2 = nil
        ch3 = nil
        ch4 = nil
//    ch2 = Square2(mmu: mmu)
//    ch3 = Wave(mmu: mmu)
//    ch4 = Noise(mmu: mmu)
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
    }

    /// Mix the four channel outputs into left/right sample
    func mixSample() -> Int16 {
        let s1 = ch1.currentSample()
        let s2 = ch2.currentSample()
        let s3 = ch3.currentSample()
        let s4 = ch4.currentSample()
        // simple sum; you’ll apply the NR51 NR52 masks
        return s1 &+ s2 &+ s3 &+ s4
    }
}

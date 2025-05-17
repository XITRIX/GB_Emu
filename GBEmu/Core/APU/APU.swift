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

    private let sampleRate = 48000
    private var audioClock: Double = 0
    let ring = StereoRingBuffer(capacity: 8192)

    // channel objects:
    private let ch1: APUChannelProtocol
    private let ch2: APUChannelProtocol
    private let ch3: APUChannelProtocol
    private let ch4: APUChannelProtocol

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

        audioClock += Double(cycles) * (Double(sampleRate) / 4194304)
        // (4.194304 MHz is Game-Boy T-cycle clock)
        while audioClock >= 1 {
            audioClock -= 1
            let pcm = mixStereoSample() // safe, on emu thread
            ring.write(pcm)
        }
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

    /// Returns a stereo pair of signed 16-bit samples
    func mixStereoSample() -> (left: Int16, right: Int16) {
        let nr50 = mmu.read(0xFF24)
        let nr51 = mmu.read(0xFF25)
        let nr52 = mmu.read(0xFF26)

        // if master sound disabled, just return silence
        guard (nr52 & 0x80) != 0 else {
            return (0, 0)
        }

        // channel samples
        let s1 = ch1.currentSample()
        let s2 = ch2.currentSample()
        let s3 = ch3.currentSample()
        let s4 = ch4.currentSample()

        // NR51 bits:  ch1→bit0 left, bit4 right;  ch2→bit1/5; ch3→2/6; ch4→3/7
        let enablesLeft = nr51 & 0x0F
        let enablesRight = (nr51 >> 4) & 0x0F

        // grab only the channels we want
        let sumLeft = Int(s1) * Int((enablesLeft >> 0) & 1) +
            Int(s2) * Int((enablesLeft >> 1) & 1) +
            Int(s3) * Int((enablesLeft >> 2) & 1) +
            Int(s4) * Int((enablesLeft >> 3) & 1)
        let sumRight = Int(s1) * Int((enablesRight >> 0) & 1) +
            Int(s2) * Int((enablesRight >> 1) & 1) +
            Int(s3) * Int((enablesRight >> 2) & 1) +
            Int(s4) * Int((enablesRight >> 3) & 1)

        // master volumes (each 0…7) at NR50 bits 0–2=right, 4–6=left
        let volRight = Int(nr50 & 0x07)
        let volLeft = Int((nr50 >> 4) & 0x07)

        // scale 0…7 → 0.0…1.0
        let mixRight = sumRight * volRight / 7
        let mixLeft = sumLeft * volLeft / 7

        // clamp into Int16
        func clamp(_ x: Int) -> Int16 {
            return Int16(max(min(x, Int(Int16.max)), Int(Int16.min)))
        }

        return (clamp(mixLeft), clamp(mixRight))
    }
}

//
//  NoiseChannel.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 17.05.2025.
//


/// Channel 4: Noise (LFSR) channel
class Noise: APUChannelProtocol {
    private let mmu: MMU

    init(mmu: MMU) {
        self.mmu = mmu
    }

    // MARK: — MMU-backed registers NR41–NR44

    /// Sound length load (6 bits) at 0xFF20
    private var nr41: UInt8 {
        mmu.read(0xFF20)
    }

    /// Envelope (vol, dir, period) at 0xFF21
    private var nr42: UInt8 {
        mmu.read(0xFF21)
    }

    /// Polynomial counter (divisor, width, shift) at 0xFF22
    private var nr43: UInt8 {
        mmu.read(0xFF22)
    }

    /// Counter/consecutive-select + trigger at 0xFF23
    private var nr44: UInt8 {
        get { mmu.read(0xFF23) }
        set { mmu[0xFF23] = newValue }
    }

    // MARK: — Internal state

    private var enabled        = false
    private var lengthEnabled  = false
    private var lengthCounter  = 0

    private var envelopeVolume   = 0    // 0…15
    private var envelopePeriod   = 0
    private var envelopeCounter  = 0
    private var envelopeIncrease = false

    private var lfsr       : UInt16 = 0x7FFF
    private var lfsrTimer  = 0

    // Compute the LFSR reload period in T-cycles
    private var lfsrPeriod: Int {
        let s = Int(nr43 >> 4)          // clock shift
        let r = Int(nr43 & 0x07)        // divisor code
        // r==0 → divisor = 0.5  ⇒ period = 2^(s+3)
        // else    → divisor = r    ⇒ period = r·2^(s+4)
        return r == 0
          ? (1 << (s + 3))
          : (r << (s + 4))
    }

    // MARK: — Trigger logic

    private func trigger() {
        // 1) length
        lengthCounter = 64 - Int(nr41 & 0x3F)
        lengthEnabled = (nr44 & 0x40) != 0

        // 2) envelope reload
        let initVol = Int(nr42 >> 4)
        envelopeVolume   = initVol
        envelopeIncrease = (nr42 & 0x08) != 0
        envelopePeriod   = Int(nr42 & 0x07)
        // treat period 0 as “8”
        envelopeCounter  = envelopePeriod == 0 ? 8 : envelopePeriod

        // 3) reset LFSR & timer
        lfsr      = 0x7FFF
        lfsrTimer = lfsrPeriod

        // 4) enable only if DAC would actually produce sound
        //    (initial volume>0 or envelope will run at least once)
        let dacOn = initVol > 0 || envelopePeriod > 0
        enabled = dacOn
    }

    /// Call this instead of writing directly to 0xFF23 so we catch the trigger bit
    func write(nrAddress: UInt16, value: UInt8) {
        if nrAddress == 0xFF23 {
            let prev = nr44
            nr44 = value
            // on rising edge of bit 7 → trigger
            if (value & 0x80) != 0 && (prev & 0x80) == 0 {
                trigger()
            }
        } else {
            mmu.write(value, to: nrAddress)
        }
    }

    // MARK: — APUChannelProtocol

    /// Advance the LFSR according to the noise clock
    func step(cycles: Int) {
        guard enabled else { return }
        lfsrTimer -= cycles
        let period = lfsrPeriod
        while lfsrTimer <= 0 {
            lfsrTimer += period
            // new bit = XOR(bit 0, bit 1)
            let newBit = UInt16((lfsr & 0x1) ^ ((lfsr >> 1) & 0x1))
            lfsr = (lfsr >> 1) | (newBit << 14)
            // if width mode = 7-bit, also copy into bit 6
            if (nr43 & 0x08) != 0 {
                lfsr = (lfsr & ~(1 << 6)) | (newBit << 6)
            }
        }
    }

    /// Called on frame-sequencer steps 0,2,4,6
    func clockLength() {
        guard enabled, lengthEnabled, lengthCounter > 0 else { return }
        lengthCounter -= 1
        if lengthCounter == 0 {
            enabled = false
        }
    }

    /// Called on frame-sequencer step 7
    func clockEnvelope() {
        guard enabled, envelopePeriod > 0 else { return }
        envelopeCounter -= 1
        if envelopeCounter == 0 {
            envelopeCounter = envelopePeriod
            if envelopeIncrease {
                if envelopeVolume < 15 { envelopeVolume += 1 }
            } else {
                if envelopeVolume > 0  { envelopeVolume -= 1 }
            }
        }
    }

    /// No frequency sweep on noise channel
    func clockSweep() {}

    /// Returns a 16-bit signed sample (–32768…+32767)
    func currentSample() -> Int16 {
        guard enabled, envelopeVolume > 0 else { return 0 }
        // output bit is inverted LFSR bit 0
        let bit0 = Int((lfsr & 0x1) ^ 0x1)
        // map 0/1 → –1/+1, scale by envelopeVolume
        let level = (bit0 == 1 ? 1 : -1) * envelopeVolume
        // stretch 0…15 → full Int16 range
        return Int16(clamping: Int(level) * (Int(Int16.max) / 15))
    }
}

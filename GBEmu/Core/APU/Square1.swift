//
//  Square1.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 17.05.2025.
//

import Combine

class Square1: APUChannelProtocol {
    init(mmu: MMU) {
        self.mmu = mmu

        mmu.writePublisher.sink { [unowned self] address, value in
            switch address {
                case 0xFF10: // NR10
                    // nothing to “store” yet, but next clockSweep() will read nr10
                    sweepEnabled = (nr10 & 0x07) != 0
                case 0xFF11: // NR11
                    // reload length if we want to accept mid-frame writes
                    lengthCounter = 64 - Int(value & 0x3F)
                case 0xFF12: // NR12
                    initialVolume = Int(value >> 4)
                    envelopeAdd = (value & 0x08) != 0
                    envelopePeriod = Int(value & 0x07)
                case 0xFF13, 0xFF14:
                    updateFrequency() // recompute your 11-bit freq from nr13/nr14
                    lengthEnable = (nr14 & 0x40) != 0
                    if (nr14 & 0x80) != 0 { trigger() }
                default:
                    break
            }
        }.store(in: &disposeBag)
    }

    private var disposeBag: [AnyCancellable] = []
    private let mmu: MMU

    // MARK: — Internal state
    private(set) var enabled = false

    // length counter
    private var lengthCounter = 0
    private var lengthEnable = false

    // envelope
    private var initialVolume = 0
    private var envelopeAdd = false
    private var envelopePeriod = 0
    private var envelopeTimer = 0
    private var volume = 0

    // sweep
    private var sweepTimer = 0
    private var sweepEnabled = false
    private var shadowFrequency = 0

    // waveform timing
    private var dutyStep = 0
    private var timer = 0
    private var frequency = 0 // 0..2047
}

private extension Square1 {
    // MARK: — Registers (NR10–NR14)
    /// Sweep register
    private var nr10: UInt8 {
        mmu.read(0xFF10)
    }

    private var nr11: UInt8 {
        mmu.read(0xFF11)
    }

    private var nr12: UInt8 {
        mmu.read(0xFF12)
    }

    private var nr13: UInt8 {
        mmu.read(0xFF13)
    }

    private var nr14: UInt8 {
        mmu.read(0xFF14)
    }
}

extension Square1 {
    // MARK: — Trigger / reset
    private func trigger() {
        enabled = true
        // reload length if zero
        if lengthCounter == 0 {
            lengthCounter = 64 - Int(nr11 & 0x3F)
        }
        // envelope
        volume = initialVolume
        envelopeTimer = (envelopePeriod == 0 ? 8 : envelopePeriod)

        // sweep
        shadowFrequency = frequency
        sweepTimer = (sweepPeriod == 0 ? 8 : sweepPeriod)
        sweepEnabled = sweepShift > 0

        // waveform
        dutyStep = 0
        timer = (2048 - frequency) * 4
    }

    // MARK: — Register-derived helpers
    private var sweepPeriod: Int { Int((nr10 & 0x70) >> 4) }
    private var sweepNegate: Bool { (nr10 & 0x08) != 0 }
    private var sweepShift: Int { Int(nr10 & 0x07) }

    private func updateFrequency() {
        // 11-bit freq from NR14[2:0]<<8 | NR13
        let hi = Int(nr14 & 0x07) << 8
        let lo = Int(nr13)
        frequency = hi | lo
    }

    // MARK: — APUChannelProtocol

    /// Called each T-cycle count. Advances the duty-wave timer.
    func step(cycles: Int) {
        guard enabled else { return }
        timer -= cycles
        while timer <= 0 {
            timer += (2048 - frequency) * 4
            dutyStep = (dutyStep + 1) & 0x07
        }
    }

    /// Called on frame-sequencer steps 0,2,4,6
    func clockLength() {
        guard enabled, lengthEnable else { return }
        lengthCounter -= 1
        if lengthCounter <= 0 {
            enabled = false
        }
    }

    /// Called on frame-sequencer step 7
    func clockEnvelope() {
        guard envelopePeriod > 0, enabled else { return }
        envelopeTimer -= 1
        if envelopeTimer <= 0 {
            envelopeTimer = envelopePeriod
            if envelopeAdd {
                if volume < 15 { volume += 1 }
            } else {
                if volume > 0 { volume -= 1 }
            }
        }
    }

    /// Called on frame-sequencer steps 2 & 6
    func clockSweep() {
        guard sweepEnabled, enabled else { return }
        sweepTimer -= 1
        if sweepTimer <= 0 {
            sweepTimer = (sweepPeriod == 0 ? 8 : sweepPeriod)
            let delta = shadowFrequency >> sweepShift
            let newFreq = sweepNegate
                ? shadowFrequency &- delta
                : shadowFrequency &+ delta

            if newFreq > 2047 {
                enabled = false
            } else if sweepShift > 0 {
                shadowFrequency = newFreq
                frequency = newFreq
            }
        }
    }

    /// Called by your mixer to get the current PCM sample
    func currentSample() -> Int16 {
        guard enabled else { return 0 }
        // pick duty pattern
        let dutyIndex = Int((nr11 & 0xC0) >> 6)
        let bit = APUDutyTable[dutyIndex][dutyStep]
        // produce 0..volume
        return Int16(clamping: Int(bit) * Int(volume))
    }
}

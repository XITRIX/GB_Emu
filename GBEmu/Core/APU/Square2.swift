//
//  Square2Channel.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 17.05.2025.
//

class Square2: APUChannelProtocol {
  private let mmu: MMU

  init(mmu: MMU) {
    self.mmu = mmu
  }

  // MARK: — MMU-backed “registers” NR21–NR24

  private var nr21: UInt8 {
    get { mmu.read(0xFF16) }
    set { mmu.write(newValue, to: 0xFF16) }
  }

  private var nr22: UInt8 {
    get { mmu.read(0xFF17) }
    set { mmu.write(newValue, to: 0xFF17) }
  }

  private var nr23: UInt8 {
    get { mmu.read(0xFF18) }
    set { mmu.write(newValue, to: 0xFF18) }
  }

  private var nr24: UInt8 {
    get { mmu.read(0xFF19) }
    set {
      mmu.write(newValue, to: 0xFF19)
      // length enable (bit6)
      lengthEnable = (newValue & 0x40) != 0
      // update the 11-bit freq
      updateFrequency()
      // trigger if bit7 set
      if (newValue & 0x80) != 0 {
        trigger()
      }
    }
  }

  // MARK: — Internal state

  private var enabled = false

  // length counter
  private var lengthCounter = 0
  private var lengthEnable  = false

  // envelope
  private var initialVolume = 0
  private var envelopeAdd    = false
  private var envelopePeriod = 0
  private var envelopeTimer  = 0
  private var volume         = 0

  // waveform timing
  private var dutyStep = 0
  private var timer    = 0
  private var frequency = 0  // 0..2047

  // MARK: — Trigger / reset

  private func trigger() {
    enabled = true

    // reload length: 6-bit value in NR21 bits0–5 (zero→64)
    let loadLen = Int(nr21 & 0x3F)
    lengthCounter = loadLen == 0 ? 64 : loadLen

    // reload envelope from NR22
    initialVolume = Int((nr22 & 0xF0) >> 4)
    envelopeAdd    = (nr22 & 0x08) != 0
    envelopePeriod = Int(nr22 & 0x07)
    volume         = initialVolume
    envelopeTimer  = envelopePeriod == 0 ? 8 : envelopePeriod

    // reset waveform timing
    dutyStep = 0
    timer    = (2048 - frequency) * 4
  }

  // MARK: — Computed helpers

  private func updateFrequency() {
    let hi = Int(nr24 & 0x07) << 8
    let lo = Int(nr23)
    frequency = hi | lo
  }

  // MARK: — APUChannelProtocol

  /// Called each T-cycle batch
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
    guard enabled, envelopePeriod > 0 else { return }
    envelopeTimer -= 1
    if envelopeTimer <= 0 {
      envelopeTimer = envelopePeriod
      if envelopeAdd {
        if volume < 15 { volume += 1 }
      } else {
        if volume > 0  { volume -= 1 }
      }
    }
  }

  /// No sweep on channel 2
  func clockSweep() {
    // no-op
  }

  /// Read current PCM sample (–32768..+32767)
  func currentSample() -> Int16 {
    guard enabled else { return 0 }
    let dutyIndex = Int((nr21 & 0xC0) >> 6)
    let bit = APUDutyTable[dutyIndex][dutyStep]
    return Int16(bit) * Int16(volume) * Int16(Int16.max) / 15
  }
}

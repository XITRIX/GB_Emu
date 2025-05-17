//
//  WaveChannel.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 17.05.2025.
//


/// Channel 3: Wave (PCM) channel
class Wave: APUChannelProtocol {
  private let mmu: MMU

  init(mmu: MMU) {
    self.mmu = mmu
  }

  // MARK: — MMU-backed registers NR30–NR34

  /// DAC power (bit 7). If 0, channel is forced off.
  private var nr30: UInt8 {
    get { mmu.read(0xFF1A) }
    set {
      mmu.write(newValue, to: 0xFF1A)
      dacEnabled = (newValue & 0x80) != 0
      if !dacEnabled { enabled = false }
    }
  }

  /// Length load (0…255 → counter = 256 − value)
  private var nr31: UInt8 {
    get { mmu.read(0xFF1B) }
    set { mmu.write(newValue, to: 0xFF1B) }
  }

  /// Output level: bits 5–6 (0=mute, 1=100%, 2=50%, 3=25%)
  private var nr32: UInt8 {
    get { mmu.read(0xFF1C) }
    set {
      mmu.write(newValue, to: 0xFF1C)
      volumeCode = Int((newValue >> 5) & 0x03)
    }
  }

  /// Frequency low 8 bits
  private var nr33: UInt8 {
    get { mmu.read(0xFF1D) }
    set {
      mmu.write(newValue, to: 0xFF1D)
      updateFrequency()
    }
  }

  /// Trigger (bit 7), length enable (bit 6), freq hi bits 0–2
  private var nr34: UInt8 {
    get { mmu.read(0xFF1E) }
    set {
      mmu.write(newValue, to: 0xFF1E)
      lengthEnable = (newValue & 0x40) != 0
      updateFrequency()
      if (newValue & 0x80) != 0 { trigger() }
    }
  }

  // MARK: — Internal state

  private var enabled      = false
  private var dacEnabled   = false
  private var lengthEnable = false

  private var lengthCounter = 0
  private var frequency     = 0    // 0…2047
  private var timer         = 0    // counts down in T-cycles
  private var sampleIndex   = 0    // 0…31 (32 4-bit samples)
  private var volumeCode    = 0    // 0=mute,1,2,3

  // MARK: — Helpers

  private func updateFrequency() {
    let lo = Int(nr33)
    let hi = Int(nr34 & 0x07) << 8
    frequency = hi | lo
  }

  private func trigger() {
    // master enable
    dacEnabled = (nr30 & 0x80) != 0
    enabled    = dacEnabled

    // reload length counter
    let rawLen = Int(nr31)
    lengthCounter = 256 - rawLen

    // reset waveform position & timer
    sampleIndex = 0
    timer       = (2048 - frequency) * 2
  }

  // MARK: — APUChannelProtocol

  /// Called each batch of T-cycles
  func step(cycles: Int) {
    guard enabled else { return }
    timer -= cycles
    while timer <= 0 {
      timer += (2048 - frequency) * 2
      sampleIndex = (sampleIndex + 1) & 0x1F
    }
  }

  /// Clocked on frame-sequencer steps 0,2,4,6
  func clockLength() {
    guard enabled, lengthEnable else { return }
    lengthCounter -= 1
    if lengthCounter <= 0 {
      enabled = false
    }
  }

  /// No envelope on wave channel
  func clockEnvelope() {}

  /// No frequency sweep on wave channel
  func clockSweep() {}

  /// Returns signed 16-bit PCM (–32768…+32767)
  func currentSample() -> Int16 {
    guard enabled else { return 0 }

    // Fetch the 4-bit sample from wave RAM
    let baseAddr = 0xFF30
    let byte      = mmu.read(UInt16(baseAddr + sampleIndex/2))
    let rawNibble = (sampleIndex & 1) == 0
      ? (byte >> 4)
      : (byte & 0x0F)

    // Apply output level
    let out: Int
    switch volumeCode {
    case 0: out = 0
    case 1: out = Int(rawNibble)
    case 2: out = Int(rawNibble) >> 1
    case 3: out = Int(rawNibble) >> 2
    default: out = 0
    }

    // Scale 0…15 → full Int16 range
    return Int16(out) * Int16(Int16.max) / 15
  }
}

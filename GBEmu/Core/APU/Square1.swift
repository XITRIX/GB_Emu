//
//  Square1.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 17.05.2025.
//

class Square1: APUChannelProtocol {
  private let mmu: MMU
  
  // length counter, envelope, sweep, frequency timer, duty
  private var length: UInt8 = 0
  private var envelopeVol: UInt8 = 0
  private var envelopePeriod: UInt8 = 0
  private var envelopeCounter = 0
  private var sweepPeriod: UInt8 = 0
  private var sweepCounter = 0
  private var sweepShift: UInt8 = 0
  private var sweepNegate: Bool = false
  
  private var freq: UInt16 = 0      // 11-bit
  private var freqTimer = 0
  private var dutyStep = 0
  
  init(mmu: MMU) {
    self.mmu = mmu
  }
  
  func step(cycles: Int) {
    // decrement frequency divider
    freqTimer -= cycles
    while freqTimer <= 0 {
      freqTimer += Int((2048 - freq) * 4)
      dutyStep = (dutyStep + 1) & 7
    }
  }
  
  func clockLength() {
    let ctrl = mmu.read(0xFF11) // NR11: length + duty
    let maxLen = 64
    if (mmu.read(0xFF12) & 0x40) != 0 { // NR14.L
      length = (length < UInt8(maxLen)) ? length &+ 1 : UInt8(maxLen)
    }
  }
  
  func clockEnvelope() {
    let nr12 = mmu.read(0xFF12)
    envelopePeriod = nr12 & 0x07
    // on each envelope tick:
    if envelopePeriod != 0 {
      if envelopeCounter >= envelopePeriod {
        envelopeCounter = 0
        let inc = (nr12 & 0x08) != 0
        if inc && envelopeVol < 15 { envelopeVol += 1 }
        if !inc && envelopeVol > 0 { envelopeVol -= 1 }
      } else {
        envelopeCounter += 1
      }
    }
  }
  
  func clockSweep() {
    let nr10 = mmu.read(0xFF10)
    let period = (nr10 >> 4) & 0x07
    let shift  = nr10 & 0x07
    let neg    = (nr10 & 0x08) != 0
    // similar scheduling: recalc freq, maybe disable channel
    // (implementation detail from Pan Docs)
  }
  
  func currentSample() -> Int16 {
    // read output enable and duty from NR51/52,
    // pick bit from a duty table [8 bytes].
    // multiply by envelopeVol, return signed 16-bit sample.
    return 0
  }
}

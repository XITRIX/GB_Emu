//
//  AudioDriver.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 17.05.2025.
//

import AVFoundation

class AudioDriver {
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode!
    private let apu: APU

    init(emulatorAPU: APU) {
        apu = emulatorAPU
        let sampleRate = 44_100.0
        let fmt = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 2,
            interleaved: false
        )!

        // Create a “pull” node
        sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0 ..< Int(frameCount) {
                // Mix one stereo sample
                let (l, r) = emulatorAPU.ring.read() ?? (0, 0)

                if l == 0, r == 0 {
//                  print("🔇 silent sample at \(Date())")
                } else {
                    print("🔊 sample = \(l),\(r)")
                }

                // convert Int16 → Float in –1…+1
                let fL = Float32(l) / Float32(Int16.max)
                let fR = Float32(r) / Float32(Int16.max)
                // write into both buffers
                abl[0].mData!.assumingMemoryBound(to: Float32.self)[frame] = fL
                abl[1].mData!.assumingMemoryBound(to: Float32.self)[frame] = fR
            }
            return noErr
        }

        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: fmt)
    }

    func start() {
        do {
            try engine.start()
        } catch {
            fatalError("Audio engine failed to start: \(error)")
        }
    }

    func stop() {
        engine.stop()
    }
}

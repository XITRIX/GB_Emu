//
//  PixelImageView.swift
//  Chip8
//
//  Created by Даниил Виноградов on 07.05.2025.
//

import CoreGraphics
import SwiftUICore

struct ImageData {
//    static var whiteColor: [UInt8] { [100, 210, 224, 255] }
//    static var blackColor: [UInt8] { [0, 0, 0, 255] }
    static var randomColor: [UInt8] { [UInt8.random(in: UInt8.min ... UInt8.max), UInt8.random(in: UInt8.min ... UInt8.max), UInt8.random(in: UInt8.min ... UInt8.max), 255] }
    private let queue = DispatchQueue(label: "Atomic-\(UUID())")

    var data: [UInt32]
    var width: Int
    var height: Int

    init(width: Int = 160, height: Int = 144) {
        data = .init(repeating: 0, count: width * height)
        self.width = width
        self.height = height
    }

    init(data: [UInt32], width: Int, height: Int) {
        self.data = data
        self.width = width
        self.height = height
    }

    func get(_ x: UInt8, _ y: UInt8) -> UInt32 {
        data[width * Int(y) + Int(x)]
    }

    mutating func set(_ x: UInt8, _ y: UInt8, _ value: UInt32) {
        data[width * Int(y) + Int(x)] = value
    }

    mutating func clear() {
        let size = width * height
        data = .init(repeating: 0, count: size)
    }

    static func mock() -> ImageData {
        let width = 160
        let height = 144
        let size = width * height

        var image: [UInt32] = []
        for _ in 0 ..< size {
            image.append(UInt32.random(in: 0 ... UInt32.max))
        }

        return ImageData(data: image, width: width, height: height)
    }
}

struct PixelImageView: View {
    @Environment(\.self) private var environment

    @Binding var pixels: ImageData

    var body: some View {
        if let image = makeCGImage(from: pixels) {
            Image(decorative: image, scale: 1.0, orientation: .up)
                .resizable()
                .interpolation(.none) // Disable smoothing
                .drawingGroup() // Force rasterization to apply interpolation setting
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "trash")
        }
    }
}

private extension PixelImageView {
    func makeCGImage(from pixelData: ImageData) -> CGImage? {
        let bytesPerPixel = 4
        let bytesPerRow = pixelData.width * bytesPerPixel
        let bitsPerComponent = 8

        var data = [UInt8]()
        data.reserveCapacity(pixelData.width * pixelData.height * 4)
        for pixel in pixelData.data {
            data.append(contentsOf: pixel.asColorData)
        }

        guard data.count == pixelData.width * pixelData.height * bytesPerPixel else {
            return nil
        }

        return data.withUnsafeBytes { ptr in
            guard let context = CGContext(
                data: UnsafeMutableRawPointer(mutating: ptr.baseAddress!),
                width: pixelData.width,
                height: pixelData.height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return nil
            }

            return context.makeImage()
        }
    }
}

extension UInt32 {
    var asColorData: [UInt8] {
        let a = UInt8((self & 0xFF000000) >> 24)
        let r = UInt8((self & 0x00FF0000) >> 16)
        let g = UInt8((self & 0x0000FF00) >> 8)
        let b = UInt8((self & 0x000000FF) >> 0)
        return [r, g, b, a]
    }
}

private extension Color.Resolved {
    var data: [UInt8] {
        [clamp(red), clamp(green), clamp(blue), 255]
    }

    private func clamp(_ x: Float) -> UInt8 {
        UInt8(max(0, min(255, Int((x * 255).rounded()))))
    }
}

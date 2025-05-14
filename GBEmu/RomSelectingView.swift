//
//  Rom.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 12.05.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct Rom: Identifiable {
    var id: URL { url }

    let title: String
    let url: URL
}

struct RomSelectingView: View {
    var roms: [Rom] = [
        .init(title: "cpu_instrs", url: Bundle.main.url(forResource: "cpu_instrs", withExtension: "gb")!),
        .init(title: "01-special", url: Bundle.main.url(forResource: "01-special", withExtension: "gb")!),
        .init(title: "02-interrupts", url: Bundle.main.url(forResource: "02-interrupts", withExtension: "gb")!),
        .init(title: "03-op sp,hl", url: Bundle.main.url(forResource: "03-op sp,hl", withExtension: "gb")!),
        .init(title: "04-op r,imm", url: Bundle.main.url(forResource: "04-op r,imm", withExtension: "gb")!),
        .init(title: "05-op rp", url: Bundle.main.url(forResource: "05-op rp", withExtension: "gb")!),
        .init(title: "06-ld r,r", url: Bundle.main.url(forResource: "06-ld r,r", withExtension: "gb")!),
        .init(title: "07-jr,jp,call,ret,rst", url: Bundle.main.url(forResource: "07-jr,jp,call,ret,rst", withExtension: "gb")!),
        .init(title: "08-misc instrs", url: Bundle.main.url(forResource: "08-misc instrs", withExtension: "gb")!),
        .init(title: "09-op r,r", url: Bundle.main.url(forResource: "09-op r,r", withExtension: "gb")!),
        .init(title: "10-bit ops", url: Bundle.main.url(forResource: "10-bit ops", withExtension: "gb")!),
        .init(title: "11-op a,(hl)", url: Bundle.main.url(forResource: "11-op a,(hl)", withExtension: "gb")!),
        .init(title: "2048", url: Bundle.main.url(forResource: "2048", withExtension: "gb")!),
    ]

    @State private var importFile: Bool = false
    @State private var romData: Data?

//    private let ch8Type = UTType(importedAs: "com.xitrix.chip8", conformingTo: .data)
    private let gbType = UTType(importedAs: "com.xitrix.gb", conformingTo: .data)

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(roms) { rom in
                        NavigationLink(rom.title) {
                            let data = try! Data(contentsOf: rom.url)
                            EmulatorView(rom: data)
                                .navigationTitle(rom.title)
                        }
                    }
                    Button {
                        importFile = true
                    } label: {
                        Text("Import ROM")
                    }
                }
            }
            .navigationTitle("GameBoy")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: Binding(
                get: { romData != nil },
                set: { if !$0 { romData = nil } }
            )) {
                if let data = romData {
                    EmulatorView(rom: data)
                }
            }
            .fileImporter(isPresented: $importFile, allowedContentTypes: [gbType]) { result in
                switch result {
                case .success(let url):
                    guard url.startAccessingSecurityScopedResource()
                    else { return }
                    defer { url.stopAccessingSecurityScopedResource() }

                    if let data = try? Data(contentsOf: url) {
                        romData = data
                    }
                case .failure(let error):
                    print("File import failed: \(error)")
                }
            }
        }
    }
}

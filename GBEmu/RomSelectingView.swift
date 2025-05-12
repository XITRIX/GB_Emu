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
//    var roms: [Rom] = [
//        .init(title: "cpu_instrs", url: Bundle.main.url(forResource: "cpu_instrs", withExtension: "bg")!),
//    ]

    @State private var importFile: Bool = false
    @State private var romData: Data?

//    private let ch8Type = UTType(importedAs: "com.xitrix.chip8", conformingTo: .data)
    private let gbType = UTType(importedAs: "com.xitrix.gb", conformingTo: .data)

    var body: some View {
        NavigationStack {
            List {
                Section {
//                    ForEach(roms) { rom in
//                        NavigationLink(rom.title) {
//                            let data = try! Data(contentsOf: rom.url)
//                            EmptyView()
//                                .navigationTitle(rom.title)
//                        }
//                    }
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

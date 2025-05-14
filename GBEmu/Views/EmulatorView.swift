//
//  EmulatorView.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 12.05.2025.
//

import SwiftUI

@Observable
class EmulatorViewModel {
    var joypadState: UInt8 = 0xFF {
        didSet {
            emu.joypadState = joypadState
        }
    }

    init(rom: Data) {
        emu = .init(rom: rom)
    }

    func start() {
        emu.start()
    }

    func stop() {}

    private let emu: Emu
}

struct EmulatorView: View {
    @State var viewModel: EmulatorViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(rom: Data) {
        _viewModel = State(initialValue: .init(rom: rom))
    }

    var body: some View {
        VStack {
            EmptyView()
                .frame(width: 320, height: 240)

            KeyboardView(keysInput: $viewModel.joypadState)
        }
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .onAppear {
                viewModel.start()
            }
            .onDisappear {
                viewModel.stop()
            }
    }
}

#Preview {
    RomSelectingView()
}

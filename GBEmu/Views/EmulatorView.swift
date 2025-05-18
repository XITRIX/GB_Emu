//
//  EmulatorView.swift
//  GBEmu
//
//  Created by Даниил Виноградов on 12.05.2025.
//

import SwiftUI
import GameController

@Observable
class EmulatorViewModel {
    var imageData: ImageData = .init()
    private(set) var isRunning: Bool = false
    
    @ObservationIgnored @Published var logs: String = ""

    var joypadState: UInt8 = 0xFF {
        didSet {
            emu.joypadState = joypadState
        }
    }

    init(rom: Data) {
        Logger.shared.$logs
            .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: true)
            .map { $0.joined(separator: "") }
            .assign(to: &$logs)

        emu = .init(rom: rom) { framebuffer in
            self.imageData.data = framebuffer
        }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        emu.start()
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        emu.stop()
    }

    func setKeyPressed(_ isPressed: Bool, at index: UInt8) {
        if isPressed {
            joypadState &= ~index
        } else {
            joypadState |= index
        }
    }

    private var emu: Emu!
}

struct EmulatorView: View {
    @State private var viewModel: EmulatorViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let virtualController: GCVirtualController
    @State var isLogsVisible: Bool = false

    init(rom: Data) {
        _viewModel = State(initialValue: .init(rom: rom))

        let configuration = GCVirtualController.Configuration()
        configuration.elements = [GCInputDirectionPad, GCInputButtonB, GCInputButtonA, GCInputButtonX, GCInputButtonY]
        virtualController = GCVirtualController(configuration: configuration)
    }

    var body: some View {
        VStack {
            if isLogsVisible {
                ScrollView {
                    TextEditor(text: .constant(viewModel.logs))
                        .disabled(true)
                    //                    .ignoresSafeArea(.all, edges: .top)
                }
                .frame(minHeight: 380)
                //            .ignoresSafeArea(.all, edges: .top)
                .defaultScrollAnchor(.bottom)
            }

            PixelImageView(pixels: $viewModel.imageData)
                .frame(width: 320, height: 240)

//            Spacer()
//
//            KeyboardView(keysInput: $viewModel.joypadState)
        }
        .ignoresSafeArea(.all, edges: .top)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isLogsVisible.toggle()
                } label: {
                    if isLogsVisible {
                        Image(systemName: "apple.terminal.fill")
                    } else {
                        Image(systemName: "apple.terminal")
                    }
                }


                if viewModel.isRunning {
                    Button {
                        viewModel.stop()
                    } label: {
                        Image(systemName: "pause.fill")
                    }
                }
                else {
                    Button {
                        viewModel.start()
                    } label: {
                        Image(systemName: "play.fill")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .onAppear {
            viewModel.start()
            virtualController.connect()

            if let controller = virtualController.controller?.extendedGamepad {
                controller.buttonA.valueChangedHandler = { [viewModel] _, _, pressed in viewModel.setKeyPressed(pressed, at: 1 << 0) }
                controller.buttonB.valueChangedHandler = { [viewModel] _, _, pressed in viewModel.setKeyPressed(pressed, at: 1 << 1) }
                controller.buttonX.valueChangedHandler = { [viewModel] _, _, pressed in viewModel.setKeyPressed(pressed, at: 1 << 2) }
                controller.buttonY.valueChangedHandler = { [viewModel] _, _, pressed in viewModel.setKeyPressed(pressed, at: 1 << 3) }
                controller.dpad.right.valueChangedHandler = { [viewModel] _, _, pressed in viewModel.setKeyPressed(pressed, at: 1 << 4) }
                controller.dpad.left.valueChangedHandler = { [viewModel] _, _, pressed in viewModel.setKeyPressed(pressed, at: 1 << 5) }
                controller.dpad.up.valueChangedHandler = { [viewModel] _, _, pressed in viewModel.setKeyPressed(pressed, at: 1 << 6) }
                controller.dpad.down.valueChangedHandler = { [viewModel] _, _, pressed in viewModel.setKeyPressed(pressed, at: 1 << 7) }
            }
        }
        .onDisappear {
            viewModel.stop()
            virtualController.disconnect()
        }
    }
}

#Preview {
    RomSelectingView()
}

//
//  KeyboardView.swift
//  Chip8
//
//  Created by Даниил Виноградов on 08.05.2025.
//

import SwiftUI

struct KeyboardView: View {
    @Binding var keysInput: UInt8

    var body: some View {
        HStack {
            VStack {
                HStack {
                    EmptyKeySpace()
                    KeyboardButton(keysInput: $keysInput, index: 1 << 6, label: "U")
                    EmptyKeySpace()
                }
                HStack {
                    KeyboardButton(keysInput: $keysInput, index: 1 << 5, label: "L")
                    EmptyKeySpace()
                    KeyboardButton(keysInput: $keysInput, index: 1 << 4, label: "R")
                }
                HStack {
                    EmptyKeySpace()
                    KeyboardButton(keysInput: $keysInput, index: 1 << 7, label: "D")
                    EmptyKeySpace()
                }
            }

            Spacer()

            VStack {
                HStack {
                    EmptyKeySpace()
                    EmptyKeySpace()
                }
                HStack {
                    KeyboardButton(keysInput: $keysInput, index: 1 << 2, label: "Select")
                    KeyboardButton(keysInput: $keysInput, index: 1 << 3, label: "Start")
                }
            }

            Spacer()

            VStack {
                HStack {
                    EmptyKeySpace()
                    KeyboardButton(keysInput: $keysInput, index: 1 << 0, label: "A")
                }
                HStack {
                    KeyboardButton(keysInput: $keysInput, index: 1 << 1, label: "B")
                    EmptyKeySpace()
                }
            }
        }
    }
}

struct EmptyKeySpace: View {
    var body: some View {
        Spacer()
            .background(Color.orange)
            .frame(width: 54, height: 54)
    }
}

struct KeyboardButton: View {
    @Binding var keysInput: UInt8
    let index: UInt8
    let label: String

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        } label: {
            Text(label)
                .frame(width: 54, height: 54)
        }
        .buttonRepeatBehavior(.enabled)
//        .buttonStyle(.borderedProminent)
        .buttonStyle(TouchTrackingButtonStyle { isPressed in
            if isPressed {
                keysInput &= ~index
            } else {
                keysInput |= index
            }
        })
    }
}

struct TouchTrackingButtonStyle: ButtonStyle {
    @GestureState private var isPressed = false
    let action: (Bool) -> Void

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title)
            .fontWeight(.semibold)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
            )
            .onChange(of: isPressed) { newValue in
//                print("Touch status: \(newValue)") // true on press, false on release
                action(isPressed)
            }
    }
}

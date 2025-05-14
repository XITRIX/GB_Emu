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
        VStack {
            HStack {
                KeyboardButton(keysInput: $keysInput, index: 1 << 0, label: "A")
                KeyboardButton(keysInput: $keysInput, index: 1 << 1, label: "B")
                KeyboardButton(keysInput: $keysInput, index: 1 << 2, label: "Select")
                KeyboardButton(keysInput: $keysInput, index: 1 << 3, label: "Start")
            }
            HStack {
                KeyboardButton(keysInput: $keysInput, index: 1 << 4, label: "R")
                KeyboardButton(keysInput: $keysInput, index: 1 << 5, label: "L")
                KeyboardButton(keysInput: $keysInput, index: 1 << 6, label: "U")
                KeyboardButton(keysInput: $keysInput, index: 1 << 7, label: "D")
            }
        }
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

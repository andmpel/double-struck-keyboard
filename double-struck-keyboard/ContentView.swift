//
//  ContentView.swift
//  double-struck-keyboard
//
//  Created by Andrew Pelletier on 8/26/25.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var input = ""
    @State private var didCopy = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Double-Struck Converter")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Input")
                    .font(.headline)
                TextEditor(text: $input)
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary))
                
                Text("Output")
                    .font(.headline)
                Text(DoubleStruckMapper.map(input))
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                    .padding(4)
                    .background(Color(.systemBackground))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary))
                    .font(.body)
                    .textSelection(.enabled)
                
                Button {
                    let textToCopy = DoubleStruckMapper.map(input)
                    if #available(iOS 16.0, *) {
                        UIPasteboard.general.setItems([[UTType.plainText.identifier: textToCopy]])
                    } else {
                        UIPasteboard.general.string = textToCopy
                    }
                    didCopy = true
                } label: {
                    Text(didCopy ? "Copied!" : "Copy")
                        .frame(maxWidth: 80, minHeight: 32)
                        .background(didCopy ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                        .foregroundColor(didCopy ? .green : .blue)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .onChange(of: didCopy) { _, newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            didCopy = false
                        }
                    }
                }
                
                Text("To use the keyboard:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Settings → General → Keyboard → Keyboards → Add New Keyboard → double-struck-keyboard")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("𝔻𝕊 Keyboard")
        }
    }
}

#Preview {
    ContentView()
}

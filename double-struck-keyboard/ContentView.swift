//
//  ContentView.swift
//  double-struck-keyboard
//
//  Created by Andrew Pelletier on 8/26/25.
//

import SwiftUI

struct ContentView: View {
    @State private var input = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Double-Struck Converter")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Input")
                    .font(.headline)
                TextEditor(text: $input)
                    .frame( maxWidth: .infinity,minHeight: 120)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary))
                
                Text("Output")
                    .font(.headline)
                Text(DoubleStruckMapper.map(input))
                    .frame( maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                    .padding(4)
                    .background(Color(.systemBackground))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary))
                    .font(.body)
                    .textSelection(.enabled)
                
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

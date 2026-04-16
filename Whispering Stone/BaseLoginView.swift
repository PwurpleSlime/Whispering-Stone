//
//  baseLoginView.swift
//  Whispering Stone
//
//  Created by Pwurple on 4/15/26.
//
import SwiftUI
import ClerkKit
import ClerkKitUI

struct baseLoginView: View {
    @State private var authIsPresented = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Whispering Stone")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Ask questions. Get answers.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Sign In / Sign Up") {
                authIsPresented = true
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $authIsPresented) {
            AuthView()   // ✅ Correct view name in ClerkKitUI 1.x
        }
    }
}

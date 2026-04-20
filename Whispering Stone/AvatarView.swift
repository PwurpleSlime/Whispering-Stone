//
//  AvatarView.swift
//  Whispering Stone
//
//  Created by Pwurple on 4/16/26.
//


import SwiftUI

struct AvatarView: View {
    let name: String?
    var size: CGFloat = 28

    private var initial: String {
        String(name?.first ?? "?").uppercased()
    }

    var body: some View {
        Circle()
            .fill(Color(.systemGray4))
            .frame(width: size, height: size)
            .overlay(
                Text(initial)
                    .font(.system(size: size * 0.42, weight: .medium))
                    .foregroundColor(.secondary)
            )
    }
}
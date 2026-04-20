//
//  CreatePostView.swift
//  Whispering Stone
//
//  Created by Pwurple on 4/16/26.
//


import SwiftUI
import ClerkKit

struct CreatePostView: View {
    let userId: String
    let authorName: String
    
    @State private var title = ""
    @State private var mainContent  = ""
    @State private var tag   = ""
    @State private var isPosting = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostViewModel

    var canPost: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty &&
                        !mainContent.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    field(label: "Title",
                          placeholder: "What's your question?",
                          text: $title)

                    field(label: "Tags",
                          placeholder: "e.g. Swift, iOS, General",
                          text: $tag)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Body")
                            .font(.title2).fontWeight(.bold)
                        TextEditor(text: $mainContent)
                            .frame(minHeight: 220)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                Group {
                                    if mainContent.isEmpty {
                                        Text("Describe your question in detail...")
                                            .foregroundColor(Color(.placeholderText))
                                            .padding(14)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity,
                                                   alignment: .topLeading)
                                            .allowsHitTesting(false)
                                    }
                                }
                            )
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .frame(width: 30, height: 30)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    .foregroundColor(.primary)
                }
                ToolbarItem(placement: .principal) {
                    Text("New Post").fontWeight(.semibold)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        isPosting = true
                        Task {
                            await vm.createPost(
                                title: title,
                                body: mainContent,
                                tag: tag,
                                userId: userId,
                                authorName: authorName
                            )
                            dismiss()
                        }
                    } label: {
                        Text(isPosting ? "Posting…" : "Post")
                            .fontWeight(.semibold)
                    }
                    .disabled(!canPost || isPosting)
                }
            }
        }
    }

    @ViewBuilder
    private func field(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.title2).fontWeight(.bold)
            TextField(placeholder, text: text)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}

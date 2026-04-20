//
//  EditPostView.swift
//  Whispering Stone
//
//  Created by Pwurple on 4/16/26.
//


import SwiftUI

struct EditPostView: View {
    let postId: String

    @State private var title: String
    @State private var mainContent: String
    @State private var tag: String
    @State private var isSaving = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: PostViewModel

    init(postId: String, initialTitle: String, initialBody: String, initialTag: String) {
        self.postId = postId
        _title = State(initialValue: initialTitle)
        _mainContent = State(initialValue: initialBody)
        _tag = State(initialValue: initialTag)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    editField(label: "Title", text: $title)
                    editField(label: "Tags", text: $tag)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Body").font(.title2).fontWeight(.bold)
                        TextEditor(text: $mainContent)
                            .frame(minHeight: 200)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit Post").fontWeight(.semibold)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Saving…" : "Save") {
                        guard !isSaving else { return }
                        isSaving = true

                        Task {
                            await vm.updatePost(
                                postId: postId,
                                title: title,
                                body: mainContent,
                                tag: tag.isEmpty ? "TAG" : tag
                            )
                            dismiss()
                        }
                    }
                    .disabled(isSaving)
                }            }
        }
    }

    @ViewBuilder
    private func editField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.title2).fontWeight(.bold)
            TextField(label, text: text)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}

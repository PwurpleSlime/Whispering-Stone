import SwiftUI
import ClerkKit
import ClerkKitUI

struct ContentView: View {
    @Environment(Clerk.self) private var clerk

    var body: some View {
        NavigationStack {   // ✅ ONLY ONE NavigationStack in app

            if let userId = clerk.user?.id {
                PostFeedView(userId: userId)
            } else {
                baseLoginView()
            }
        }
    }
}

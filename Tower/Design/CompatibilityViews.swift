import SwiftUI

/// Uses the single-column navigation behavior on iOS 15, avoiding the empty
/// detail column that a plain `NavigationView` can show on iPad.
struct TowerNavigation<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationView {
            content
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

/// A lightweight iOS 15 equivalent of `TowerUnavailableContentView`.
struct TowerUnavailableContentView: View {
    private let title: Text
    private let symbol: String
    private let detail: Text?

    init(_ title: String, systemImage: String, description: Text? = nil) {
        self.title = Text(title)
        self.symbol = systemImage
        self.detail = description
    }

    static func search(text: String) -> TowerUnavailableContentView {
        TowerUnavailableContentView(
            String(localized: "没有“\(text)”的结果"),
            systemImage: "magnifyingglass",
            description: Text("请调整搜索词后重试。")
        )
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.secondary)
            title
                .font(.headline)
                .multilineTextAlignment(.center)
            if let detail {
                detail
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .accessibilityElement(children: .combine)
    }
}

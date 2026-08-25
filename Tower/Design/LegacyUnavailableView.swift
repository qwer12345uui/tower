import SwiftUI

/// A lightweight iOS 15 replacement for ContentUnavailableView.
struct LegacyUnavailableView: View {
    let title: String
    let systemImage: String
    let detail: String?

    init(_ title: String, systemImage: String, detail: String? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.detail = detail
    }

    static func search(text: String) -> LegacyUnavailableView {
        LegacyUnavailableView(
            "未找到结果",
            systemImage: "magnifyingglass",
            detail: text.isEmpty ? nil : "没有与“\(text)”匹配的内容。"
        )
    }

    var body: some View {
        VStack(spacing: 9) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
            if let detail, !detail.isEmpty {
                Text(detail)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
    }
}

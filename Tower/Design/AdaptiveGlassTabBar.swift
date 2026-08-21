import SwiftUI

/// A self-contained bottom navigation surface that intentionally uses only
/// iOS 15 SwiftUI materials and system colors. Its large, equal-width targets
/// keep the visual treatment from reducing the reliability of tab selection.
struct AdaptiveGlassTabBar: View {
    @Binding var selection: AppTab

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool {
        colorScheme == .dark
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(AppTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(6)
        .background(glassSurface)
        .overlay {
            RoundedRectangle(cornerRadius: 31, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        }
        .shadow(
            color: isDark ? Color.black.opacity(0.52) : Color.black.opacity(0.14),
            radius: isDark ? 18 : 15,
            y: 7
        )
        .animation(
            reduceMotion ? .easeOut(duration: 0.12) : .spring(response: 0.30, dampingFraction: 0.88),
            value: selection
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("主导航")
    }

    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selection == tab

        return Button {
            selection = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(height: 24)

                Text(tab.title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(foregroundColor(selected: isSelected))
            .frame(maxWidth: .infinity, minHeight: 52)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(selectionFill)
                        .overlay {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(selectionBorder, lineWidth: 0.75)
                        }
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "当前页面" : "切换到\(tab.title)页面")
    }

    @ViewBuilder
    private var glassSurface: some View {
        if reduceTransparency {
            RoundedRectangle(cornerRadius: 31, style: .continuous)
                .fill(fallbackSurfaceColor)
                .overlay {
                    RoundedRectangle(cornerRadius: 31, style: .continuous)
                        .fill(surfaceTint)
                }
        } else {
            RoundedRectangle(cornerRadius: 31, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 31, style: .continuous)
                        .fill(surfaceTint)
                }
        }
    }

    private var fallbackSurfaceColor: Color {
        Color(uiColor: isDark ? .secondarySystemBackground : .systemBackground)
    }

    private var surfaceTint: Color {
        isDark ? Color.black.opacity(reduceTransparency ? 0 : 0.26) : Color.white.opacity(reduceTransparency ? 0 : 0.48)
    }

    private var borderColor: Color {
        isDark ? Color.white.opacity(0.24) : Color.white.opacity(0.88)
    }

    private var selectionFill: Color {
        if isDark {
            return Color.accentColor.opacity(0.36)
        }
        return Color.accentColor.opacity(0.14)
    }

    private var selectionBorder: Color {
        isDark ? Color.white.opacity(0.22) : Color.white.opacity(0.70)
    }

    private func foregroundColor(selected: Bool) -> Color {
        if selected {
            return isDark ? .white : .accentColor
        }
        return isDark ? Color.white.opacity(0.82) : .primary
    }
}

import SwiftUI

/// A self-contained floating tab surface that uses only iOS 15 materials and
/// system colors. Its three equal-width buttons keep tab selection predictable
/// without adding a gesture that could compete with page or list scrolling.
struct AdaptiveGlassTabBar: View {
    @Binding var selection: AppTab

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool {
        colorScheme == .dark
    }

    private var selectionAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.18)
            : .interactiveSpring(response: 0.28, dampingFraction: 0.88, blendDuration: 0.12)
    }

    var body: some View {
        HStack(spacing: 5) {
            ForEach(AppTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(5)
        .background(glassSurface)
        .overlay {
            Capsule()
                .stroke(borderColor, lineWidth: isDark ? 0.9 : 0.7)
        }
        .shadow(
            color: Color.black.opacity(isDark ? 0.30 : 0.12),
            radius: isDark ? 16 : 13,
            y: isDark ? 8 : 6
        )
        .animation(selectionAnimation, value: selection)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("主导航")
    }

    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selection == tab

        return Button {
            selection = tab
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.symbol)
                    .font(.system(size: 19, weight: .bold))
                    .frame(height: 23)

                Text(tab.title)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .foregroundStyle(foregroundColor(selected: isSelected))
            .frame(maxWidth: .infinity, minHeight: 50)
            .background {
                if isSelected {
                    Capsule()
                        .fill(selectionFill)
                        .overlay {
                            Capsule()
                                .stroke(selectionBorder, lineWidth: 0.7)
                        }
                        .shadow(
                            color: Color.pink.opacity(isDark ? 0.20 : 0.12),
                            radius: 7,
                            y: 3
                        )
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(GlassTabPressStyle())
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "当前页面" : "切换到\(tab.title)页面")
    }

    @ViewBuilder
    private var glassSurface: some View {
        if reduceTransparency {
            Capsule()
                .fill(fallbackSurfaceColor)
        } else {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .fill(surfaceTint)
                }
        }
    }

    private var fallbackSurfaceColor: Color {
        Color(uiColor: isDark ? .secondarySystemBackground : .systemBackground)
    }

    private var surfaceTint: Color {
        isDark ? Color.black.opacity(0.24) : Color.white.opacity(0.44)
    }

    private var borderColor: Color {
        isDark ? Color.white.opacity(0.30) : Color.white.opacity(0.90)
    }

    private var selectionFill: Color {
        Color.pink.opacity(isDark ? 0.44 : 0.18)
    }

    private var selectionBorder: Color {
        isDark ? Color.pink.opacity(0.58) : Color.white.opacity(0.78)
    }

    private func foregroundColor(selected: Bool) -> Color {
        if selected {
            return isDark ? .white : .pink
        }
        return isDark ? Color.white.opacity(0.86) : Color.primary.opacity(0.62)
    }
}

private struct GlassTabPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(
                reduceMotion
                    ? .easeOut(duration: 0.12)
                    : .interactiveSpring(response: 0.20, dampingFraction: 0.90),
                value: configuration.isPressed
            )
    }
}

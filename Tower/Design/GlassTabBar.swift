import SwiftUI

/// A floating tab control with the soft, translucent capsule treatment used by
/// the app's main navigation. The material automatically follows the system
/// appearance; opaque system colors remain available when accessibility asks
/// to reduce transparency.
struct GlassTabBar: View {
    @Binding var selection: AppTab

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                GlassTabButton(
                    tab: tab,
                    isSelected: selection == tab,
                    colorScheme: colorScheme,
                    action: {
                        withAnimation(reduceMotion ? .easeOut(duration: 0.16) : .spring(response: 0.32, dampingFraction: 0.82)) {
                            selection = tab
                        }
                    }
                )
            }
        }
        .padding(6)
        .background(glassBackground)
        .overlay {
            Capsule()
                .stroke(glassBorder, lineWidth: 0.85)
        }
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.34 : 0.16), radius: 16, y: 7)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("主导航")
    }

    @ViewBuilder
    private var glassBackground: some View {
        ZStack {
            if reduceTransparency {
                Capsule().fill(fallbackSurface)
            } else {
                Capsule().fill(.ultraThinMaterial)
            }
            Capsule()
                .fill(colorScheme == .dark ? Color.blue.opacity(0.10) : Color.white.opacity(0.20))
        }
    }

    private var fallbackSurface: Color {
        Color(uiColor: colorScheme == .dark ? .tertiarySystemFill : .secondarySystemBackground)
    }

    private var glassBorder: Color {
        colorScheme == .dark ? Color.white.opacity(0.17) : Color.white.opacity(0.72)
    }
}

private struct GlassTabButton: View {
    let tab: AppTab
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.symbol)
                    .font(.system(size: 18, weight: isSelected ? .bold : .semibold))
                    .frame(height: 22)
                Text(tab.title)
                    .font(.caption2.weight(isSelected ? .bold : .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, minHeight: 55)
            .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            .background {
                if isSelected {
                    Capsule()
                        .fill(selectedSurface)
                        .overlay {
                            Capsule()
                                .stroke(selectedBorder, lineWidth: 0.6)
                        }
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(ResponsivePressButtonStyle())
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "当前标签" : "切换到此标签")
    }

    private var selectedSurface: Color {
        colorScheme == .dark ? Color.accentColor.opacity(0.30) : Color.accentColor.opacity(0.13)
    }

    private var selectedBorder: Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color.white.opacity(0.48)
    }
}

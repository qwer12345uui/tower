import SwiftUI
import UIKit

/// Three equal-width tab controls presented in a floating glass capsule.
///
/// The bar deliberately uses ordinary `Button` controls rather than a drag
/// gesture. That leaves vertical content scrolling and the system's tab
/// container gesture arbitration untouched, while still giving every tab a
/// generous, predictable hit target.
struct GlassTabBar: View {
    @Binding var selection: AppTab

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme

    private var selectionAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.18)
            : .interactiveSpring(response: 0.28, dampingFraction: 0.86, blendDuration: 0.12)
    }

    var body: some View {
        HStack(spacing: 5) {
            ForEach(AppTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(5)
        .background { barBackground }
        .overlay {
            Capsule()
                .stroke(borderColor, lineWidth: colorScheme == .dark ? 0.9 : 0.7)
        }
        .shadow(
            color: .black.opacity(colorScheme == .dark ? 0.28 : 0.12),
            radius: colorScheme == .dark ? 16 : 13,
            y: colorScheme == .dark ? 8 : 6
        )
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var barBackground: some View {
        if reduceTransparency {
            Capsule()
                .fill(Color(uiColor: colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
        } else {
            Capsule()
                .fill(.ultraThinMaterial)
        }
    }

    private var borderColor: Color {
        colorScheme == .dark
            ? .white.opacity(0.28)
            : .white.opacity(0.88)
    }

    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selection == tab

        return Button {
            select(tab)
        } label: {
            Label(tab.title, systemImage: tab.symbol)
                .font(.subheadline.weight(.bold))
                .symbolRenderingMode(.hierarchical)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, minHeight: 46)
                .contentShape(Rectangle())
                .foregroundStyle(labelColor(isSelected: isSelected))
                .background {
                    if isSelected {
                        Capsule()
                            .fill(selectionFill)
                            .overlay {
                                Capsule()
                                    .stroke(selectionBorder, lineWidth: 0.7)
                            }
                            .shadow(
                                color: Color.pink.opacity(colorScheme == .dark ? 0.18 : 0.12),
                                radius: 7,
                                y: 3
                            )
                    }
                }
        }
        .buttonStyle(GlassTabButtonStyle())
        .accessibilityLabel(Text(tab.title))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(selectionAnimation, value: selection)
    }

    private var selectionFill: Color {
        Color.pink.opacity(colorScheme == .dark ? 0.42 : 0.18)
    }

    private var selectionBorder: Color {
        colorScheme == .dark
            ? Color.pink.opacity(0.58)
            : .white.opacity(0.74)
    }

    private func labelColor(isSelected: Bool) -> Color {
        guard isSelected else {
            return colorScheme == .dark ? .white.opacity(0.84) : .primary.opacity(0.62)
        }
        return colorScheme == .dark ? .white : .pink
    }

    private func select(_ tab: AppTab) {
        guard selection != tab else { return }

        let feedback = UISelectionFeedbackGenerator()
        feedback.prepare()
        feedback.selectionChanged()

        withAnimation(selectionAnimation) {
            selection = tab
        }
    }
}

private struct GlassTabButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(
                reduceMotion ? .easeOut(duration: 0.12) : .interactiveSpring(response: 0.2, dampingFraction: 0.9),
                value: configuration.isPressed
            )
    }
}

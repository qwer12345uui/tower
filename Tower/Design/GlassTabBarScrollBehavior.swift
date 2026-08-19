import SwiftUI

/// Keeps the floating navigation out of the way while reading long content.
/// The gesture observes rather than replaces a scroll view's own pan gesture,
/// and deliberately ignores horizontal movement so `PageTabViewStyle` remains
/// free to handle tab-to-tab swipes.
struct GlassTabBarScrollBehavior: ViewModifier {
    @EnvironmentObject private var model: AppModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var lastDirection: VerticalScrollDirection?

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 12)
                    .onChanged { value in
                        let translation = value.translation
                        guard abs(translation.height) > abs(translation.width) * 1.35 else { return }

                        if translation.height < -16 {
                            updateNavigation(isCollapsed: true, direction: .up)
                        } else if translation.height > 12 {
                            updateNavigation(isCollapsed: false, direction: .down)
                        }
                    }
                    .onEnded { value in
                        let translation = value.predictedEndTranslation
                        guard abs(translation.height) > abs(translation.width) * 1.35 else {
                            lastDirection = nil
                            return
                        }

                        if translation.height > 18 {
                            updateNavigation(isCollapsed: false, direction: .down)
                        }
                        lastDirection = nil
                    }
            )
    }

    private func updateNavigation(isCollapsed: Bool, direction: VerticalScrollDirection) {
        guard lastDirection != direction || model.isGlassTabBarCollapsed != isCollapsed else { return }
        lastDirection = direction
        guard model.isGlassTabBarCollapsed != isCollapsed else { return }

        withAnimation(reduceMotion ? .easeOut(duration: 0.14) : .spring(response: 0.30, dampingFraction: 0.88)) {
            model.isGlassTabBarCollapsed = isCollapsed
        }
    }
}

private enum VerticalScrollDirection: Equatable {
    case up
    case down
}

extension View {
    /// Adds direction-aware glass navigation behavior to a primary vertical
    /// scroll surface without claiming or cancelling its pan gesture.
    func glassTabBarScrollBehavior() -> some View {
        modifier(GlassTabBarScrollBehavior())
    }
}

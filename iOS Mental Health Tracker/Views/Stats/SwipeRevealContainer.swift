//
//  SwipeRevealContainer.swift
//  iOS Mental Health Tracker
//

import SwiftUI

/// Shows `content`, with `panel` hidden off the trailing edge. Swiping left pulls the
/// panel in; swiping right (or setting `isRevealed` to false) pushes it back out.
///
/// The drag state lives here rather than in the parent, so the content and panel views
/// aren't rebuilt on every frame of the swipe.
struct SwipeRevealContainer<Content: View, Panel: View>: View {
    @Binding var isRevealed: Bool
    let content: Content
    let panel: Panel

    @State private var dragOffset: CGFloat = 0
    @State private var isHorizontalDrag: Bool?
    @AppStorage("hasSeenStatsSwipeHint") private var hasSeenHint = false

    private let spring = Animation.spring(response: 0.35, dampingFraction: 0.86)

    init(isRevealed: Binding<Bool>, @ViewBuilder content: () -> Content, @ViewBuilder panel: () -> Panel) {
        _isRevealed = isRevealed
        self.content = content()
        self.panel = panel()
    }

    var body: some View {
        GeometryReader { geometry in
            let width = max(geometry.size.width, 1)
            // Dragging left (negative offset) reveals more of the panel
            let reveal = min(max((isRevealed ? width : 0) - dragOffset, 0), width)
            let progress = reveal / width

            ZStack(alignment: .trailing) {
                content
                    .offset(x: -reveal * 0.25)
                    .overlay {
                        Color.black
                            .opacity(0.5 * progress)
                            .ignoresSafeArea()
                            .allowsHitTesting(false)
                    }
                    .accessibilityHidden(isRevealed)

                edgeHandle
                    .offset(x: -reveal)
                    .opacity(1 - progress)

                panel
                    .frame(width: width)
                    .offset(x: width - reveal)
                    .accessibilityHidden(!isRevealed)
            }
            .simultaneousGesture(dragGesture(width: width))
            .task {
                await showHintIfNeeded()
            }
        }
    }

    /// A small grabber on the trailing edge, so the gesture is discoverable and tappable.
    private var edgeHandle: some View {
        Button {
            withAnimation(spring) {
                isRevealed = true
            }
        } label: {
            Capsule()
                .fill(AppTheme.secondaryTextColor.opacity(0.5))
                .frame(width: 4, height: 40)
                .padding(.trailing, 2)
                .frame(width: 16, height: 88, alignment: .trailing)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Year in review")
        .accessibilityHint("Shows your stats for the year")
    }

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 15)
            .onChanged { value in
                // Decide once per drag, so vertical scrolling never moves the panel
                if isHorizontalDrag == nil {
                    isHorizontalDrag = abs(value.translation.width) > abs(value.translation.height) * 1.2
                }
                guard isHorizontalDrag == true else { return }
                dragOffset = value.translation.width
            }
            .onEnded { value in
                defer { isHorizontalDrag = nil }
                guard isHorizontalDrag == true else { return }

                let moved = value.translation.width
                let predicted = value.predictedEndTranslation.width
                withAnimation(spring) {
                    if isRevealed {
                        if moved > width * 0.25 || predicted > width * 0.5 {
                            isRevealed = false
                        }
                    } else if moved < -width * 0.25 || predicted < -width * 0.5 {
                        isRevealed = true
                        hasSeenHint = true
                    }
                    dragOffset = 0
                }
            }
    }

    /// The first time the calendar appears, nudge it left to hint at the panel behind it.
    private func showHintIfNeeded() async {
        guard !hasSeenHint, !isRevealed else { return }
        try? await Task.sleep(for: .seconds(1))
        guard !isRevealed else { return }
        withAnimation(spring) { dragOffset = -48 }
        try? await Task.sleep(for: .seconds(0.6))
        withAnimation(spring) { dragOffset = 0 }
        hasSeenHint = true
    }
}

import SwiftUI

struct TrafficLightView: View {
    @Binding var selectedMood: MoodState?
    @State private var pressedMood: MoodState?
    let onSelect: (MoodState) -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(MoodState.allCases, id: \.self) { mood in
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedMood = mood
                            onSelect(mood)
                            pressedMood = nil
                        }
                    }) {
                        Circle()
                            .fill(mood.color)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary.opacity(0.2), lineWidth: selectedMood == mood ? 3 : 0)
                            )
                            .scaleEffect(pressedMood == mood ? 0.95 : (selectedMood == mood ? 1.2 : 1.0))
                            .shadow(color: mood.color.opacity(selectedMood == mood ? 0.5 : 0), radius: 10, x: 0, y: 5)
                            .opacity(selectedMood == mood ? 1.0 : 0.9)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if pressedMood != mood {
                                    pressedMood = mood
                                }
                            }
                            .onEnded { _ in
                                pressedMood = nil
                            }
                    )
                    .accessibilityLabel(mood.displayName)
                    .accessibilityHint("Select \(mood.displayName) mood")
                    .accessibilityAddTraits(selectedMood == mood ? .isSelected : [])
                    .accessibilityValue(selectedMood == mood ? "Selected" : "Not selected")
                    
                    Text(mood.displayName)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.vertical, 20)
    }
}


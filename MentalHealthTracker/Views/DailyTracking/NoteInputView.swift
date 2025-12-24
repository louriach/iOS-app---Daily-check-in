import SwiftUI

struct NoteInputView: View {
    @Binding var noteType: DailyTrackingViewModel.NoteType
    @Binding var textNote: String
    let characterLimit: Int = 240
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Note Type", selection: $noteType) {
                Text("Text Note").tag(DailyTrackingViewModel.NoteType.text)
                Text("Voice Note").tag(DailyTrackingViewModel.NoteType.voice)
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Note type selector")
            
            if noteType == .text {
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: Binding(
                        get: { textNote },
                        set: { newValue in
                            if newValue.count <= characterLimit {
                                textNote = newValue
                            }
                        }
                    ))
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(textNote.count > characterLimit ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .accessibilityLabel("Text note input")
                    .accessibilityHint("Enter up to \(characterLimit) characters")
                    
                    Text("\(textNote.count)/\(characterLimit)")
                        .font(.caption)
                        .foregroundColor(textNote.count > characterLimit ? .red : .secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .padding()
    }
}


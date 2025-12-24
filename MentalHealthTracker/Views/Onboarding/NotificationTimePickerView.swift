import SwiftUI

struct NotificationTimePickerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("When would you like to check in?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("We'll send you a gentle reminder each day")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            DatePicker(
                "Notification Time",
                selection: $viewModel.selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .padding()
            
            Spacer()
            
            Button(action: {
                Task {
                    await viewModel.completeOnboarding()
                    if viewModel.errorMessage == nil {
                        onComplete()
                    }
                }
            }) {
                HStack {
                    if viewModel.isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(viewModel.isSaving ? "Setting up..." : "Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .cornerRadius(12)
            }
            .disabled(viewModel.isSaving)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .accessibilityLabel("Continue button")
            .accessibilityHint("Complete onboarding and set up notifications")
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .accessibilityLabel("Error message: \(errorMessage)")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Notification time picker")
    }
}


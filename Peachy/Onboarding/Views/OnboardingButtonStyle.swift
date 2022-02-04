import SwiftUI

struct OnboardingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(configuration.isPressed ? Color(NSColor.selectedControlColor) : Color(NSColor.controlAccentColor))
            .foregroundColor(.white)
            .cornerRadius(4)
    }
}

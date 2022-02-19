import SwiftUI

struct OnboardingButton: ButtonStyle {

    var isPrimary: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                configuration.isPressed ?
                (isPrimary ? Color(.selectedControlColor) : Color(NSColor.darkGray)) :
                    (isPrimary ? Color(.controlAccentColor) : Color(NSColor.systemGray))
            )
            .foregroundColor(.white)
            .cornerRadius(4)
    }
}

#if DEBUG
struct OnboardingButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Test", action: {})
            .buttonStyle(OnboardingButton(isPrimary: false))
            .padding(30)
    }
}
#endif

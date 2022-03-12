import SwiftUI

struct PilotView: View {
    private let preferences: AppPreferences
    private let onOpenBrowser: () -> Void
    private let onComplete: () -> Void

    init(preferences: AppPreferences,
         onOpenBrowser: @escaping () -> Void,
         onComplete: @escaping () -> Void) {
        self.preferences = preferences
        self.onComplete = onComplete
        self.onOpenBrowser = onOpenBrowser
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("You're all set!")
                .font(.largeTitle)

            Text("You can now enter kaomojis in any app by typing \"\(preferences.triggerKey)\" preceding a keyword.")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 320)

            AnimatedImage(imageName: "pilot")

            HStack(spacing: 4) {
                Text("Need inspirations?")
                
                Button(action: onOpenBrowser) {
                    Text("Visit Peachy's Browser.")
                        .foregroundColor(Color(NSColor.controlAccentColor))
                }
                .buttonStyle(.plain)

            }

            Button("Let's Go!", action: onComplete)
                .buttonStyle(OnboardingButton())

        }
        .padding(32)
    }
}

struct AnimatedImage: NSViewRepresentable {
    let imageName: String

    func makeNSView(context: Self.Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.image = NSImage(data: NSDataAsset(name: imageName)!.data)
        imageView.animates = true
        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context: NSViewRepresentableContext<AnimatedImage>) {
    }
}

import SwiftUI

struct PilotView: View {
    private let triggerKey: String
    private let onPreferences: () -> Void
    private let onComplete: () -> Void

    init(triggerKey: String,
         onPreferences: @escaping () -> Void,
         onComplete: @escaping () -> Void) {
        self.triggerKey = triggerKey
        self.onComplete = onComplete
        self.onPreferences = onPreferences
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("You're all set!")
                .font(.largeTitle)
            
            Text("You can now enter kaomojis in any app by typing \"\(triggerKey)\" preceding a keyword.")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 320)
            
            AnimatedImage(imageName: "pilot")

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

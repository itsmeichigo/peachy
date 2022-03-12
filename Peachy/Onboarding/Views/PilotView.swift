import Quartz
import SwiftUI

struct PilotView: View {
    private let onOpenBrowser: () -> Void
    private let onComplete: () -> Void

    init(onOpenBrowser: @escaping () -> Void,
         onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        self.onOpenBrowser = onOpenBrowser
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("You're all set!")
                .font(.largeTitle)

            Text("You can now enter kaomojis in any app!")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 320)

            if let url = Bundle.main.url(forResource: "demo", withExtension: "gif") {
                AnimatedImage(url: url)
            }

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
    var url: URL
    
    func makeNSView(context: NSViewRepresentableContext<AnimatedImage>) -> QLPreviewView {
        let preview = QLPreviewView(frame: .zero, style: .normal)
        preview?.autostarts = true
        preview?.previewItem = url as QLPreviewItem
        
        return preview ?? QLPreviewView()
    }
    
    func updateNSView(_ nsView: QLPreviewView, context: NSViewRepresentableContext<AnimatedImage>) {
        nsView.previewItem = url as QLPreviewItem
    }
    
    typealias NSViewType = QLPreviewView
}

import SwiftUI

struct WelcomeView: View {
    private let onContinue: () -> Void

    init(onContinue: @escaping () -> Void) {
        self.onContinue = onContinue
    }

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 0) {
                Text("Hello there (｡･ω･)ﾉﾞ")
                    .font(.largeTitle)
                Image("peach-colored")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24)
            }
            .padding(.bottom, 24)
            
            Text("Peachy adds more fun to your conversations with kaomojis ♪┏(・o･)┛♪┗ ( ･o･) ┓♪")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 320)

            Image("search-window")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 320)
            
            Button("Continue", action: onContinue)
        }
    }
}

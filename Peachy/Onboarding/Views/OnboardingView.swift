import SwiftUI

struct OnboardingView: View {
    
    @State private var currentIndex: Int = 0
    private let pages: [OnboardingPage]
    
    init(pages: [OnboardingPage]) {
        self.pages = pages
    }
    
    var body: some View {
        VStack {
            ForEach(0..<pages.count, id: \.self) { index in
                if index == currentIndex {
                    pages[currentIndex].view
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeIn, value: currentIndex)
            
        }
        .frame(width: 500, height: 500)
    }
}

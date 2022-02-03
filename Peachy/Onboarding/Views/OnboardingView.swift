import SwiftUI

struct OnboardingView: View {
    
    @State private var currentIndex: Int = 0
    @State private var reverseDirection: Bool = false
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
            .transition(AnyTransition.asymmetric(
                insertion: .move(edge: reverseDirection ? .leading : .trailing),
                removal: .move(edge: reverseDirection ? .trailing : .leading))
            )
            .animation(.default, value: currentIndex)
            
            HStack {
                if pages[currentIndex].shouldShowPreviousButton {
                    Button(action: showPreviousPage, label: {
                        Text("Prev")
                    })
                    .padding(EdgeInsets(top: 0, leading: 50, bottom: 50, trailing: 50))
                }
                
                Spacer()
                
                if pages[currentIndex].shouldShowNextButton {
                    Button(action: showNextPage, label: {
                        Text("Next")
                    })
                        .padding(EdgeInsets(top: 0, leading: 50, bottom: 50, trailing: 50))
                }
            }
            
            
        }
        .frame(width: 800, height: 600)
    }
    
    private func showPreviousPage() {
        guard currentIndex > 0 else {
            return
        }
        reverseDirection = true
        currentIndex -= 1
    }
    
    private func showNextPage() {
        guard currentIndex < pages.count - 1 else {
            return
        }
        reverseDirection = false
        currentIndex += 1
    }
}

import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var viewModel: OnboardingViewModel
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ForEach(0..<viewModel.pages.count, id: \.self) { index in
                if index == viewModel.currentIndex {
                    contentView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeIn, value: viewModel.currentIndex)
            
        }
        .frame(width: 500, height: 500)
    }

    @ViewBuilder
    var contentView: some View {
        switch viewModel.currentPage {
        case .welcome:
            WelcomeView {
                viewModel.currentIndex += 1
            }
        case .permission:
            PermissionView()
        case .pilot:
            PilotView(onComplete: viewModel.completionHandler)
        }
    }
}

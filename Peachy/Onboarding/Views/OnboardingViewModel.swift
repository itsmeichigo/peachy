import Combine
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    let pages: [OnboardingPage]

    var currentPage: OnboardingPage {
        pages[currentIndex]
    }

    @Published var currentIndex: Int = 0

    private(set) var completionHandler: () -> Void

    private var timerSubscription: Cancellable?
    private var currentPageSubscription: Cancellable?

    init(pages: [OnboardingPage], onCompletion: @escaping () -> Void) {
        self.pages = pages
        self.completionHandler = onCompletion
        observeCurrentPage()
    }

    private func observeCurrentPage() {
        currentPageSubscription = $currentIndex
            .compactMap { [weak self] index in
                self?.pages[index]
            }
            .sink { [weak self] currentPage in
                if currentPage == .permission {
                    self?.setupPeriodicChecks()
                }
            }
    }

    private func setupPeriodicChecks() {
        timerSubscription = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.checkPermission()
            }
    }

    private func checkPermission() {
        guard AppState.current.hasAXPermission else {
            return
        }
        timerSubscription?.cancel()
        currentIndex += 1
        NSApp.orderedWindows.first?.orderFrontRegardless()
    }
}

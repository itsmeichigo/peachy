import Combine
import Cocoa
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    let pages: [OnboardingPage]

    var currentView: some View {
        pages[currentIndex].view
    }

    @Published private(set) var currentIndex: Int = 0

    private let completionHandler: () -> Void

    private let checkOptions = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false] as CFDictionary

    private var timerSubscription: Cancellable?

    init(pages: [OnboardingPage], onCompletion: @escaping () -> Void) {
        self.pages = pages
        self.completionHandler = onCompletion
        setupPeriodicChecks()
    }

    private func setupPeriodicChecks() {
        guard pages.first == .permission else {
            return
        }
        timerSubscription = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.checkPermission()
            }
    }

    private func checkPermission() {
        guard AXIsProcessTrustedWithOptions(checkOptions) else {
            return
        }
        timerSubscription?.cancel()
        if currentIndex < pages.count - 1 {
            currentIndex += 1
            NSApp.orderedWindows.first?.orderFrontRegardless()
        } else {
            completionHandler()
        }
    }
}

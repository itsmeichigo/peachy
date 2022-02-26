import Combine
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    let pages: [OnboardingPage]
    let triggerKey: String

    var currentPage: OnboardingPage {
        pages[currentIndex]
    }

    @Published var currentIndex: Int = 0

    private(set) var permissionGrantedHandler: () -> Void
    private(set) var preferencesHandler: () -> Void
    private(set) var completionHandler: () -> Void
    private(set) var preferences: AppPreferences

    private var timerSubscription: Cancellable?
    private var currentPageSubscription: Cancellable?

    init(pages: [OnboardingPage],
         preferences: AppPreferences,
         onPermissionGranted: @escaping () -> Void,
         onPreferences: @escaping () -> Void,
         onCompletion: @escaping () -> Void) {
        self.pages = pages
        self.preferencesHandler = onPreferences
        self.permissionGrantedHandler = onPermissionGranted
        self.completionHandler = onCompletion
        self.triggerKey = preferences.triggerKey
        self.preferences = preferences
        observeCurrentPage()
    }

    func moveToNextPage() {
        if currentIndex < pages.count - 1 {
            currentIndex += 1
            if !NSApp.isActive {
                NSApp.activate(ignoringOtherApps: true)
            }
        } else {
            completionHandler()
        }
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
        guard AppState.hasAXPermission else {
            return
        }
        timerSubscription?.cancel()
        permissionGrantedHandler()
        moveToNextPage()
    }
}

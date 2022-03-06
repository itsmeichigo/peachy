import Combine
import Foundation
import AppKit

final class BrowserViewModel: ObservableObject {
    private let appStateManager: AppStateManager
    private let kaomojiStore: KaomojiStore
    private var subscriptions: Set<AnyCancellable> = []

    weak var parentWindow: NSWindow? {
        didSet {
            updateContentTitle()
        }
    }

    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager
        self.kaomojiStore = .shared
        updateKaomojiList()
    }

    @Published var query: String = ""
    @Published var selectedTag: String?
    @Published var kaomojis: [Kaomoji] = []

    private func updateKaomojiList() {
        kaomojiStore.$allKaomojis.combineLatest($query, $selectedTag)
            .map { [weak self] items, query, tag -> [Kaomoji] in
                guard let self = self else { return [] }
                if !query.isEmpty {
                    let normalized = query.lowercased()
                    return items.filter { $0.tags.first { $0.contains(normalized) } != nil }
                } else if let tag = tag {
                    return items.filter { $0.tags.contains(tag) }
                } else {
                    return items.filter { self.appStateManager.recentKaomojis.contains($0.string) }
                }
            }
            .assign(to: &$kaomojis)
    }

    private func updateContentTitle() {
        $query.combineLatest($selectedTag)
            .map { query, tag -> String in
                if !query.isEmpty {
                    return "Search all"
                } else if let tag = tag {
                    return "#\(tag)"
                } else {
                    return "Recent Kaomojis"
                }
            }
            .sink { [weak self] title in
                self?.parentWindow?.title = title
            }
            .store(in: &subscriptions)
    }
}

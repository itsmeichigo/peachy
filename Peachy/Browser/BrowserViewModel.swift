import Combine
import Foundation

final class BrowserViewModel: ObservableObject {
    private let appStateManager: AppStateManager
    private let kaomojiStore: KaomojiStore

    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager
        self.kaomojiStore = .shared
        updateKaomojiList()
        updateContentTitle()
    }

    @Published var contentTitle: String = ""
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
                    return "Search results for \(query)"
                } else if let tag = tag {
                    return "Kaomojis with tag #\(tag)"
                } else {
                    return "Recent Kaomojis"
                }
            }
            .assign(to: &$contentTitle)
    }
}

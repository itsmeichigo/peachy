import Foundation

struct Kaomoji: Decodable, Hashable {
    public let string: String
    public let category: String?
    public let description: String?
    public let aliases: [String]?
    public let tags: [String]
}

private extension Kaomoji {
    static func parse(from fileURL: URL) -> [Kaomoji] {
        do {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            let decoder = JSONDecoder()
            let list = try decoder.decode([Kaomoji].self, from: data)
            return list
        } catch {
            return []
        }
    }
}

final class KaomojiStore {
    @Published var allKaomojis: [Kaomoji] = []
    @Published var kaomojisByTag: [String: [Kaomoji]] = [:]
    
    static let shared = KaomojiStore()
    private static let itemPerGroup: Int = 7
    
    init() {
        guard let kaomojiURL = Bundle.main.url(forResource: "kaomoji", withExtension: "json") else {
            return
        }
        
        $allKaomojis
            .map { kaomojis in
                var kaomojiResult: [String: [Kaomoji]] = [:]
                for tag in KaomojiTags.allCases {
                    kaomojiResult[tag.rawValue] = kaomojis.filter { $0.tags.contains(tag.rawValue) }
                }
                return kaomojiResult
            }
            .assign(to: &$kaomojisByTag)
        
        FilePublisher(fileURL: kaomojiURL)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .decode(type: [Kaomoji].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .assign(to: &$allKaomojis)
    }
}

enum KaomojiTags: String, CaseIterable {
    case animals, angry, bear, bird, cat, confused, crazy, cry,
         dance, dead, dog, embarassed, evil, excited, fun,
         happy, hide, hug, hurt, kiss, laugh, love,
         monkey, music, pig, rabbit, run, sad, scared,
         sleep, sorry, smug, stare, surprised, surrender,
         think, troll, wave, whatever, wink, worried, write
    case seaCreatures = "sea creatures"
    case tableFlip = "table flip"
}

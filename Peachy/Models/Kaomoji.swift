import Foundation

struct Kaomoji: Decodable, Hashable {
    public let string: String
    public let tags: [String]
}

final class KaomojiStore {
    @Published var allKaomojis: [Kaomoji] = []
    @Published var kaomojisByTag: [String: [Kaomoji]] = [:]
    let kaomojiTags = KaomojiTags.allCases.map { $0.rawValue }.sorted()
    
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
    case animals, angry, bear, bird, cat, confused, crazy, cry, cheer,
         dance, dead, dog, embarassed, evil, excited, fun, food,
         happy, hide, hug, hungry, hurt, kiss, laugh, love, exercise,
         monkey, music, pig, rabbit, run, sad, scared, smoke, punch,
         sleep, sorry, smug, stare, surprised, surrender, sing, shrug,
         think, troll, wave, whatever, wink, worried, write
    case seaCreatures = "sea creatures"
    case tableFlip = "table flip"
}

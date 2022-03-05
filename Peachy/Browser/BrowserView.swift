import SwiftUI

struct BrowserView: View {
    private let kaomojiStore = KaomojiStore.shared
    @State private var query: String = ""
    @State private var selectedTag: String?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                searchBar
                
                List(selection: $selectedTag) {
                    Text("TAGS")
                        .bold()
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(kaomojiStore.kaomojiTags, id: \.self) { tag in
                        Text("#\(tag)")
                            .padding(.leading, 8)
                    }
                }
                .listStyle(.sidebar)
            }
            Text("Content")
        }
        .frame(minWidth: 640, minHeight: 480)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                } label: {
                    Image(systemName: "sidebar.leading")
                }
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 12, height: 12)
            TextField("Search", text: $query)
                .textFieldStyle(.plain)
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color(NSColor.lightGray))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(10)
        .padding([.horizontal, .top], 8)
    }
}

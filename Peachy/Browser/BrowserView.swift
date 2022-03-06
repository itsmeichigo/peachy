import SwiftUI

struct BrowserView: View {
    @State private var selectedKaomoji: Kaomoji?
    @ObservedObject private var viewModel: BrowserViewModel

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 120))]
    }

    init(viewModel: BrowserViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                searchBar
                
                List(selection: $viewModel.selectedTag) {
                    Text("TAGS")
                        .bold()
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(KaomojiTags.all, id: \.self) { tag in
                        Text("#\(tag)")
                            .padding(.leading, 8)
                    }
                }
                .listStyle(.sidebar)
            }

            VStack(alignment: .leading, spacing: 32) {
                Text(viewModel.contentTitle)
                    .font(.title)

                kaomojiGrid
            }
            .padding(16)
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
            TextField("Search", text: $viewModel.query)
                .textFieldStyle(.plain)
            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
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

    private var kaomojiGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading) {
                ForEach(viewModel.kaomojis) { item in
                    Button(action: {
                        selectedKaomoji = item
                    }) {
                        Text(item.string)
                            .padding(16)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedKaomoji == item ? Color(NSColor.controlAccentColor) : Color(NSColor.lightGray),
                                                lineWidth: selectedKaomoji == item ? 2 : 1))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(4)
                }
            }
        }
    }
}

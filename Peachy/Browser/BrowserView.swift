import SwiftUI

struct BrowserView: View {
    @State private var selectedKaomoji: Kaomoji?
    @State private var selectedKaomojiIDs = Set<Kaomoji.ID>()
    @State private var showingDetail: Bool = false
    @ObservedObject private var viewModel: BrowserViewModel

    private let topPositionID: UUID = UUID()

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 120))]
    }

    init(viewModel: BrowserViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            List(selection: $viewModel.selectedTag) {
                Text("TAGS")
                    .bold()
                    .font(.caption)
                    .foregroundColor(.secondary)
                ForEach(viewModel.kaomojiTags, id: \.self) { tag in
                    Text(tag.isEmpty ? "All" : "#\(tag)")
                        .padding(.leading, 8)
                }
            }
            .listStyle(.sidebar)

            VStack(alignment: .leading, spacing: 0) {
                if viewModel.displayMode == .grid {
                    kaomojiGrid.padding(.leading, 16)
                } else {
                    kaomojiList
                }
                

                if let item = selectedKaomoji {
                    BrowserDetailView(kaomoji: item) {
                        withAnimation {
                            selectedKaomoji = nil
                        }
                    }
                    .transition(.move(edge: .bottom))

                    // This is a hack - setting a "transparent" button to receive the shortcut.
                    // The button title has to be the selected item so that it can be reloaded when the selected item changes, which makes the shortcut works properly.
                    Button(action: {
                        BrowserViewModel.copyToPasteBoard(content: item.string)
                    }, label: {
                        Text(item.string)
                            .frame(width: 0, height: 0)
                            .foregroundColor(.clear)
                    })
                    .buttonStyle(.plain)
                    .keyboardShortcut(.init("c"), modifiers: [.command])
                }
            }
        }
        .onChange(of: viewModel.kaomojis) { list in
            if selectedKaomoji != nil {
                selectedKaomoji = list.first
            }
        }
        .onChange(of: selectedKaomojiIDs) { ids in
            if ids.count == 1, let id = ids.first {
                selectedKaomoji = viewModel.kaomojis.first(where: { $0.id == id })
            } else {
                selectedKaomoji = nil
            }
        }
        .frame(minWidth: 640, minHeight: 480)
    }

    @ViewBuilder
    private var kaomojiList: some View {
        if #available(macOS 12, *) {
            Table(viewModel.kaomojis, selection: $selectedKaomojiIDs) {
                TableColumn("Kaomoji") { item in
                    Text(item.string)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button(action: {
                                BrowserViewModel.copyToPasteBoard(content: item.string)
                            }) {
                                Text("Copy Kaomoji")
                            }
                        }
                }
                TableColumn("Tags") { item in
                    Text(item.tags.map { "#\($0)" }.joined(separator: ", "))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
            }
        } else {
            EmptyView()
        }
    }

    private var kaomojiGrid: some View {
        ScrollView {
            ScrollViewReader { proxy in
                Spacer().frame(height: 16)
                    .id(topPositionID)
                    .onChange(of: viewModel.kaomojis) { _ in
                        proxy.scrollTo(topPositionID, anchor: .top)
                    }

                LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
                    ForEach(viewModel.kaomojis) { item in
                        kaomojiItem(item).padding(.trailing, 16)
                    }
                }

                Spacer().frame(height: 16)
            }
        }
    }

    private func kaomojiItem(_ item: Kaomoji) -> some View {
        Button(action: {
            viewModel.makeSearchFieldResignFirstResponder()
            if selectedKaomoji == nil {
                withAnimation {
                    selectedKaomoji = item
                }
            } else {
                selectedKaomoji = item
            }
        }) {
            Text(item.string)
                .padding(16)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedKaomoji == item ? Color(NSColor.controlAccentColor) : Color(NSColor.lightGray),
                                    lineWidth: selectedKaomoji == item ? 3 : 1))
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(4)
        .contextMenu {
            Button(action: {
                BrowserViewModel.copyToPasteBoard(content: item.string)
            }) {
                Text("Copy Kaomoji")
            }
        }
    }
}

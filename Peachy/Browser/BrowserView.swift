import SwiftUI

struct BrowserView: View {
    @State private var selectedKaomoji: Kaomoji?
    @State private var showingDetail: Bool = false
    @ObservedObject private var viewModel: BrowserViewModel

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
                ForEach(KaomojiTags.all, id: \.self) { tag in
                    Text("#\(tag)")
                        .padding(.leading, 8)
                }
            }
            .listStyle(.sidebar)

            VStack(alignment: .leading, spacing: 0) {
                kaomojiGrid.padding(.horizontal, 16)

                if let item = selectedKaomoji {
                    BrowserDetailView(kaomoji: item) {
                        withAnimation {
                            selectedKaomoji = nil
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .onChange(of: viewModel.kaomojis) { list in
            if selectedKaomoji != nil {
                selectedKaomoji = list.first
            }
        }
        .frame(minWidth: 640, minHeight: 480)
    }

    private var kaomojiGrid: some View {
        ScrollView {
            Spacer().frame(height: 16)
            LazyVGrid(columns: columns, alignment: .leading, pinnedViews: []) {
                ForEach(viewModel.kaomojis) { item in
                    Button(action: {
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
                            let pasteBoard = NSPasteboard.general
                            pasteBoard.clearContents()
                            pasteBoard.writeObjects([item.string as NSString])
                        }) {
                            Text("Copy Kaomoji")
                        }
                    }
                }
            }
            Spacer().frame(height: 16)
        }
    }
}

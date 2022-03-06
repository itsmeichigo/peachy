import SwiftUI

struct BrowserDetailView: View {
    private let kaomoji: Kaomoji
    private let dismissHandler: () -> Void

    init(kaomoji: Kaomoji, dismissHandler: @escaping () -> Void) {
        self.kaomoji = kaomoji
        self.dismissHandler = dismissHandler
    }

    var body: some View {
        VStack {
            Divider()
            HStack(spacing: 16) {
                Spacer()
                Button {
                    let pasteBoard = NSPasteboard.general
                    pasteBoard.clearContents()
                    pasteBoard.writeObjects([kaomoji.string as NSString])
                } label: {
                    Image(systemName: "doc.on.doc.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 16)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button {
                    dismissHandler()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)

            kaomojiText(with: kaomoji.string)
                .font(.largeTitle)
                .padding(.bottom, 16)

            ScrollView {
                HStack {
                    ForEach(kaomoji.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color(NSColor.lightGray)))
                    }
                }
                
            }
            Spacer()
        }
        .frame(height: 160)
    }

    @ViewBuilder
    private func kaomojiText(with content: String) -> some View {
        if #available(macOS 12, *) {
            Text(content).textSelection(.enabled)
        } else {
            Text(content)
        }
    }
}

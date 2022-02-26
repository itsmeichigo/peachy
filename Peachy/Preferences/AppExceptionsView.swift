import SwiftUI

struct AppExceptionsView: View {
    @State private var exceptionAppIDs: [String]
    @State private var selectedAppIndex: Int?
    @State private var exceptionListInFocus: Bool = false

    private let preferences: AppPreferences

    init(preferences: AppPreferences) {
        self.preferences = preferences
        self.exceptionAppIDs = preferences.appExceptionIDs
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Disable Peachy within these apps:")

            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(exceptionAppIDs.enumerated()), id: \.1) { (index, appID) in
                            preferences.appExceptions[appID].map(Text.init)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .frame(width: 300, alignment: .leading)
                                .foregroundColor(index == selectedAppIndex ? Color(NSColor.selectedMenuItemTextColor) : Color(NSColor.textColor))
                                .background(index == selectedAppIndex ?
                                            Color(NSColor.controlAccentColor) :
                                                Color(NSColor.textBackgroundColor))
                                .onTapGesture {
                                    selectedAppIndex = index
                                    exceptionListInFocus = true
                                }
                        }
                    }
                }
            }
            .frame(width: 300, height: 100, alignment: .leading)
            .fixedSize()
            .background(Color(NSColor.textBackgroundColor))
            .border(exceptionListInFocus ? Color(NSColor.selectedControlColor) : Color.clear, width: 4)
            .animation(.easeOut, value: exceptionListInFocus)
            .cornerRadius(4)
            
            HStack(spacing: 0) {
                Button("+") {
                    openFileBrowser()
                }
                .help("Add a new app to the exception list")
                .frame(width: 20, height: 20)

                Button("−") {
                    guard let index = selectedAppIndex else {
                        return
                    }
                    preferences.updateAppExceptions(bundleID: exceptionAppIDs[index], name: nil)
                    exceptionAppIDs.remove(at: index)
                    selectedAppIndex = nil
                }
                .help("Remove the selected app from the exception list")
                .keyboardShortcut(.delete, modifiers: [])
                .frame(width: 20, height: 20)

                Button("") {
                    guard let index = selectedAppIndex,
                          index < exceptionAppIDs.count - 1 else {
                        return
                    }
                    selectedAppIndex = index + 1
                }
                .keyboardShortcut(.downArrow, modifiers: [])

                Button("") {
                    guard let index = selectedAppIndex,
                          index > 0 else {
                        return
                    }
                    selectedAppIndex = index - 1
                }
                .keyboardShortcut(.upArrow, modifiers: [])
            }
            .font(.title2)
            .buttonStyle(.borderless)
            .background(
                Color(NSColor.controlColor)
                    .clipShape(Rectangle())
                    .cornerRadius(4)
                    .shadow(color: Color(NSColor.separatorColor), radius: 2, x: 0, y: 1)
                    .overlay(
                        Rectangle()
                            .frame(width: 1, height: 10)
                            .foregroundColor(Color(NSColor.separatorColor))
                    )
            )
        }
        .onAppear {
            exceptionListInFocus = false
            selectedAppIndex = nil
        }
    }

    private func openFileBrowser() {
        let dialog = NSOpenPanel();
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedContentTypes = [.application]
        dialog.directoryURL = URL(string: "/Applications/")
        
        if dialog.runModal() ==  NSApplication.ModalResponse.OK,
           let result = dialog.url {
            do {
                let values = try result.resourceValues(forKeys: [.localizedNameKey])
                if let name = values.localizedName,
                   let bundleID = Bundle(path: result.path)?.bundleIdentifier,
                   !exceptionAppIDs.contains(bundleID) {
                    exceptionAppIDs.append(bundleID)
                    preferences.updateAppExceptions(bundleID: bundleID, name: name)
                }
            } catch {}
            
        } else {
            // User clicked on "Cancel"
            return
        }
    }
}

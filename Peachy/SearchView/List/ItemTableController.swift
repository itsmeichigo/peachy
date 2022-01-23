import Cocoa

protocol ItemSelectionDelegate: AnyObject {
    func handleSelection(_ item: Kaomoji, withEnterKey: Bool)
}

class ItemCellView: NSTableCellView {
    static let identifier = NSUserInterfaceItemIdentifier(rawValue: "ItemCellView")
    
    @IBOutlet private var contentTextField: NSTextField!
    @IBOutlet private var tagTextField: NSTextField!
    
    func configure(item: Kaomoji) {
        contentTextField.stringValue = item.string
        tagTextField.stringValue = item.tags
            .map { "#" + $0 }
            .joined(separator: " • ")
    }
}

class ItemRowView: NSTableRowView {
    override var isEmphasized: Bool {
        get {
            return true
        }
        
        set {
            super.isEmphasized = true
        }
    }
}

class ItemTableController: NSViewController {
    
    static let rowHeight: CGFloat = 54.0
    static let rowCountPerPage: Int = 6
    
    weak var selectionDelegate: ItemSelectionDelegate?
    
    private var items: [Kaomoji] = []
    
    @available(OSX 11.0, *)
    private lazy var dataSource = makeDataSource()
    
    @IBOutlet private var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(OSX 11.0, *) {
            tableView.dataSource = dataSource
        } else {
            tableView.dataSource = self
        }
    }
    
    func triggerEvent(_ event: NSEvent) {
        tableView.keyDown(with: event)
    }
    
    /// Selection with enter key
    func confirmSelection() {
        guard let index = tableView.selectedRowIndexes.first,
              index < items.count else {
            NSSound.beep()
            return
        }
        selectionDelegate?.handleSelection(items[index], withEnterKey: true)
    }
    
    func refresh(_ items: [Kaomoji]) {
        self.items = items
        
        if #available(OSX 11.0, *) {
            update(with: items, animated: false)
        } else {
            tableView.reloadData()
        }
        
        tableView.scrollRowToVisible(0)
    }
    
    @IBAction func commitSelection(_ sender: NSTableView) {
        guard let index = sender.selectedRowIndexes.first,
              index < items.count else {
            NSSound.beep()
            return
        }
        selectionDelegate?.handleSelection(items[index], withEnterKey: false)
    }
}

extension ItemTableController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return items[row]
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: ItemCellView.identifier, owner: self) as? ItemCellView
        cellView?.configure(item: items[row])
        return cellView
    }
}

@available(OSX 11.0, *)
private extension ItemTableController {
    func makeDataSource() -> NSTableViewDiffableDataSource<Int, Kaomoji> {
        let reuseIdentifier = ItemCellView.identifier
        
        return NSTableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, column, section, menuItem in
                let cell = tableView.makeView(withIdentifier: reuseIdentifier, owner: self) as? ItemCellView
                
                cell?.configure(item: menuItem)
                return cell ?? NSView()
            }
        )
    }
    
    func update(with list: [Kaomoji], animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Kaomoji>()
        snapshot.appendSections([0])
        snapshot.appendItems(list)
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

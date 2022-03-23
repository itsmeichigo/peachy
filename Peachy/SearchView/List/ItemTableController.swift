import Cocoa

protocol ItemSelectionDelegate: AnyObject {
    func handleSelection(_ item: Kaomoji)
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
    
    private lazy var dataSource = makeDataSource()
    
    @IBOutlet private var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
    }
    
    func triggerEvent(_ event: NSEvent) {
        tableView.keyDown(with: event)
    }
    
    func confirmSelection() {
        commitSelection(tableView)
    }
    
    func refresh(_ items: [Kaomoji]) {
        self.items = items
        update(with: items, animated: false)
        tableView.scrollRowToVisible(0)
    }
    
    @IBAction func commitSelection(_ sender: NSTableView) {
        guard let index = sender.selectedRowIndexes.first,
              index < items.count else {
            NSSound.beep()
            return
        }
        selectionDelegate?.handleSelection(items[index])
    }
}

extension ItemTableController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: ItemCellView.identifier, owner: self) as? ItemCellView
        cellView?.configure(item: items[row])
        return cellView
    }
}

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

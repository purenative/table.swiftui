public protocol TableItem: Hashable {
    
    var deleteAction: TableItemAction? { get }
    var leadingActions: [TableItemAction] { get }
    var trailingActions: [TableItemAction] { get }
    
}

public extension TableItem {
    
    var deleteAction: TableItemAction? {
        nil
    }
    
    var leadingActions: [TableItemAction] {
        []
    }
    
    var trailingActions: [TableItemAction] {
        []
    }
    
}

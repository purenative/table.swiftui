import SwiftUI

public struct Table<Item: TableItem, ItemView: View>: UIViewControllerRepresentable {
    
    private let scrollResolver: TableScrollResolver?
    
    @Binding
    var items: [Item]
    
    let itemViewBuilder: (Item) -> ItemView
    
    var onActionUsed: ((IndexPath, Item, TableItemAction) -> Void)? = nil
    
    public init(scrollResolver: TableScrollResolver? = nil,
                items: Binding<[Item]>,
                itemViewBuilder: @escaping (Item) -> ItemView,
                onActionUsed: ((IndexPath, Item, TableItemAction) -> Void)? = nil) {
        
        self.scrollResolver = scrollResolver
        self._items = items
        self.itemViewBuilder = itemViewBuilder
        self.onActionUsed = onActionUsed
    }
    
    public func makeUIViewController(context: Context) -> UITableViewWrapperController<Item, ItemView> {
        let controller = UITableViewWrapperController(itemViewBuilder: itemViewBuilder) { indexPath, item, action in
            onActionUsed?(indexPath, item, action)
        }
        
        scrollResolver?.bind(resolvable: controller)
        
        return controller
    }
    
    public func updateUIViewController(_ controller: UITableViewWrapperController<Item, ItemView>,
                                context: Context) {
        
        controller.setItems(items)
        
    }
    
}

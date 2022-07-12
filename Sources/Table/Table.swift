import SwiftUI

public struct Table<Item: TableItem, Builder: TableItemViewBuilder>: UIViewControllerRepresentable where Builder.Item == Item {
    
    private let scrollResolver: TableScrollResolver?
    private let swipeActionsDismisser: TableSwipeActionsDismisser?
    
    @Binding
    var tableHeight: CGFloat
    
    @Binding
    var items: [Item]
    
    let builder: Builder
    
    var onActionUsed: ((IndexPath, Item, TableItemAction) -> Void)? = nil
    
    public init(scrollResolver: TableScrollResolver? = nil,
                swipeActionsDismisser: TableSwipeActionsDismisser? = nil,
                tableHeight: Binding<CGFloat> = .constant(.zero),
                items: Binding<[Item]>,
                builder: Builder,
                onActionUsed: ((IndexPath, Item, TableItemAction) -> Void)? = nil) {
        
        self.scrollResolver = scrollResolver
        self.swipeActionsDismisser = swipeActionsDismisser
        self._tableHeight = tableHeight
        self._items = items
        self.builder = builder
        self.onActionUsed = onActionUsed
    }
    
    public func makeUIViewController(context: Context) -> UITableViewWrapperController<Item, Builder> {
        let controller = UITableViewWrapperController<Item, Builder>(builder: builder) { indexPath, item, action in
            onActionUsed?(indexPath, item, action)
        }
        
        controller.onTableHeightChanged = {
            tableHeight = $0
        }
        
        scrollResolver?.bind(resolvable: controller)
        swipeActionsDismisser?.bind(dismissable: controller)
        
        return controller
    }
    
    public func updateUIViewController(_ controller: UITableViewWrapperController<Item, Builder>,
                                context: Context) {
        
        controller.setItems(items)
        
    }
    
}

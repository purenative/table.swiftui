import Foundation
import SwiftUI

typealias TableUpdate = (insertions: [Int], deletions: [Int])

final class TableItemsCache<Item: TableItem, Builder: TableItemViewBuilder>: TableItemViewHolderDelegate where Builder.Item == Item {
    
    private let builder: Builder
    
    private(set) var items: [Item] = []
    private var cellHeights: [CGFloat?] = []
    private var itemViewHolders: [TableItemViewHolder<AnyView>?] = []
    
    var onContentSizeChanged: (() -> Void)?
    
    var noItems: Bool {
        items.isEmpty
    }
    
    init(builder: Builder) {
        self.builder = builder
    }
    
    deinit {
        onContentSizeChanged = nil
    }
    
    func isNeedToUpdate(withItems items: [Item]) -> Bool {
        guard self.items.count == items.count else {
            return true
        }
        for index in 0..<items.count {
            if items[index].hashValue != self.items[index].hashValue {
                return true
            }
        }
        return false
    }
    
    func set(_ items: [Item]) {
        self.items.removeAll()
        self.items = items
        self.cellHeights = Array(repeating: nil, count: items.count)
        self.itemViewHolders = Array(repeating: nil, count: items.count)
    }
    
    func updateWith(newItems: [Item]) -> TableUpdate {
        
        let itemsSetAfter = Set(newItems)
        let itemsSetBefore = Set(items)
        
        let deletedItemsSet = itemsSetBefore.subtracting(itemsSetAfter)
        let insertedItemsSet = itemsSetAfter.subtracting(itemsSetBefore)
        
        let deletedIndecies = deletedItemsSet.compactMap {
            items.firstIndex(of: $0)
        }.sorted()
        let insertedIndecies = insertedItemsSet.compactMap {
            newItems.firstIndex(of: $0)
        }.sorted()
        
        for index in deletedIndecies {
            cellHeights.remove(at: index)
            itemViewHolders[index]?.detach()
            itemViewHolders.remove(at: index)
        }
        for index in insertedIndecies {
            cellHeights.insert(nil, at: index)
            itemViewHolders.insert(nil, at: index)
        }
        
        items = newItems
        
        return TableUpdate(insertedIndecies, deletedIndecies)
    }
    
    func getItem(at index: Int) -> Item {
        items[index]
    }
    
    func getHolderForItem(at index: Int) -> TableItemViewHolder<AnyView>? {
        if let holder = itemViewHolders[index] {
            holder.delegate = self
            return holder
        } else {
            let item = getItem(at: index)
            let holder = TableItemViewHolder(rootView: builder.buildView(item))
            holder.loadViewIfNeeded()
            holder.delegate = self
            cellHeights[index] = holder.itemHeight
            itemViewHolders[index] = holder
            return holder
        }
    }
    
    func getHeightForItem(at index: Int) -> CGFloat {
        if let itemHeight = cellHeights[index] {
            return itemHeight
        } else if let holder = getHolderForItem(at: index) {
            let cellHeight = holder.itemHeight
            cellHeights[index] = cellHeight
            return cellHeight
        }
        return UITableView.automaticDimension
    }
    
    func recalculateHeightFor(holder: TableItemViewHolder<AnyView>) -> Bool {
        if let index = itemViewHolders.firstIndex(of: holder), cellHeights[index] != holder.itemHeight {
            cellHeights[index] = holder.itemHeight
            return true
        }
        
        return false
    }
    
    // MARK: TableItemViewHolderDelegate
    func tableItemViewHolderDidUpdateHeight(_ controller: UIViewController?) {
        if let holder = controller as? TableItemViewHolder<AnyView> {
            if recalculateHeightFor(holder: holder) {
                onContentSizeChanged?()
            }
        }
    }
    
}

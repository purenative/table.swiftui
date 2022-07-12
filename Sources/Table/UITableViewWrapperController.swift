import UIKit
import SwiftUI

public final class UITableViewWrapperController<Item: TableItem, Builder: TableItemViewBuilder>: UIViewController, UITableViewDelegate, UITableViewDataSource, TableScrollResolvable, TableSwipeActionsDismissable where Builder.Item == Item {
    
    private let CELL_IDENTIFIER = "UITableViewWrapperItemCell"
    
    private let onActionUsed: (IndexPath, Item, TableItemAction) -> Void
    
    private var tableView: UITableView!
    
    private let cache: TableItemsCache<Item, Builder>
    
    private var tableHeightObservation: NSKeyValueObservation?
    
    private(set) var swipeActionOpened: Bool = false

    var onTableHeightChanged: ((CGFloat) -> Void)? = nil
    
    init(builder: Builder,
         onActionUsed: @escaping (IndexPath, Item, TableItemAction) -> Void) {
        
        cache = TableItemsCache(builder: builder)
        
        self.onActionUsed = onActionUsed
        
        super.init(nibName: nil,
                   bundle: nil)
        
        cache.onContentSizeChanged = { [weak self] in
            self?.layoutCells()
        }
        
        createTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    func setItems(_ items: [Item]) {
        
        if cache.noItems {
            cache.set(items)
            tableView?.reloadData()
        } else if let tableView = tableView {
            let (insertedIndecies, deletedIndecies) = cache.updateWith(newItems: items)
            
            #if DEBUG
            print("Deletions", deletedIndecies)
            print("Insertions", insertedIndecies)
            #endif
            
            let deletedIndexPaths = deletedIndecies.map {
                IndexPath(row: $0, section: .zero)
            }
            let insertedIndexPaths = insertedIndecies.map {
                IndexPath(row: $0, section: .zero)
            }
            
            tableView.performBatchUpdates {
                tableView.deleteRows(at: deletedIndexPaths,
                                     with: .fade)
                tableView.insertRows(at: insertedIndexPaths,
                                     with: .fade)
            }
        }
    }
    
    // MARK: UITableViewDelegate
    public func tableView(_ tableView: UITableView,
                          estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        cache.getHeightForItem(at: indexPath.row)
    }
    public func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
        cache.getHeightForItem(at: indexPath.row)
    }
    
    public func tableView(_ tableView: UITableView,
                          leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        swipeActionOpened = true
        
        let item = cache.getItem(at: indexPath.row)
        
        var contextualActions = [UIContextualAction]()
        
        for trailingAction in item.leadingActions {
            let contextualAction = createContextualAction(indexPath: indexPath,
                                                          item: item,
                                                          itemAction: trailingAction)
            contextualActions.append(contextualAction)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: contextualActions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    public func tableView(_ tableView: UITableView,
                          trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        swipeActionOpened = true
        
        let item = cache.getItem(at: indexPath.row)
        
        var contextualActions = [UIContextualAction]()
        
        if let deleteAction = item.deleteAction {
            deleteAction.markAsDeleteAction()
            let deleteContextualAction = createContextualAction(indexPath: indexPath,
                                                                item: item,
                                                                itemAction: deleteAction)
            contextualActions.append(deleteContextualAction)
        }
        
        for trailingAction in item.trailingActions {
            let contextualAction = createContextualAction(indexPath: indexPath,
                                                          item: item,
                                                          itemAction: trailingAction)
            contextualActions.append(contextualAction)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: contextualActions)
        configuration.performsFirstActionWithFullSwipe = item.deleteAction != nil
        return configuration
    }
    
    // MARK: UITableViewDataSource
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER,
                                                 for: indexPath) as! TableItemViewHolderCell<AnyView>
        
        if let hostingViewController = cache.getHolderForItem(at: indexPath.row) {
            cell.attach(hosting: hostingViewController,
                        withParent: self)
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        
        cache.items.count
    }
    
    // MARK: - TableScrollResolvable
    func scrollTo(index: Int, position: TableScrollResolverPosition) {
        let tableViewScrollPosition: UITableView.ScrollPosition = {
            switch position {
            case .top:
                return .top
            case .middle:
                return .middle
            case .bottom:
                return .bottom
            }
        }()
        tableView?.scrollToRow(at: IndexPath(row: index, section: .zero),
                               at: tableViewScrollPosition,
                               animated: true)
    }
    
    func scrollToOffset(_ offset: CGPoint) {
        tableView?.setContentOffset(offset,
                                    animated: true)
    }
    
    // MARK: - TableSwipeActionsDismissable
    func dismissOpenedSwipeActions() {
        if swipeActionOpened {
            #if DEBUG
            print("DISMISSED")
            #endif
            swipeActionOpened = false
            tableView?.isEditing = true
            tableView?.isEditing = false
        }
    }
    
    // MARK: - Private methods
    private func createTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(TableItemViewHolderCell<AnyView>.self,
                           forCellReuseIdentifier: CELL_IDENTIFIER)
        
        tableView.willMove(toSuperview: view)
        view.addSubview(tableView)
        tableView.didMoveToSuperview()
        
        tableHeightObservation = tableView.observe(\.contentSize, changeHandler: { [weak self] tableView, _ in
            DispatchQueue.main.async {
                self?.onTableHeightChanged?(tableView.contentSize.height)
            }
        })
    }
    
    private func layoutCells() {
        tableView.beginUpdates()
        tableView.setNeedsLayout()
        tableView.endUpdates()
    }
    
    private func createContextualAction(indexPath: IndexPath,
                                        item: Item,
                                        itemAction: TableItemAction) -> UIContextualAction {
        
        let contextualAction = UIContextualAction(style: .normal,
                                                  title: itemAction.title,
                                                  handler: { [weak self] _, _, completion in
            self?.onActionUsed(indexPath, item, itemAction)
            completion(true)
        })
        contextualAction.backgroundColor = itemAction.color
        contextualAction.image = itemAction.image
        return contextualAction
    }
    
}

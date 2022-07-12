import UIKit

protocol TableSwipeActionsDismissable: AnyObject {
    
    func dismissOpenedSwipeActions()
    
}

public final class TableSwipeActionsDismisser: TableSwipeActionsDismissable {
    
    private weak var dismissable: TableSwipeActionsDismissable?
    
    public init() {
        
    }
    
    func bind(dismissable: TableSwipeActionsDismissable) {
        self.dismissable = dismissable
    }
    
    public func dismissOpenedSwipeActions() {
        dismissable?.dismissOpenedSwipeActions()
    }
    
}

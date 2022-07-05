import Foundation
import UIKit

public enum TableScrollResolverPosition {
    
    case top
    case middle
    case bottom
    
}

protocol TableScrollResolvable: AnyObject {
    
    func scrollTo(index: Int, position: TableScrollResolverPosition)
    func scrollToOffset(_ offset: CGPoint)
    
}

public final class TableScrollResolver: TableScrollResolvable {
    
    private weak var resolvable: TableScrollResolvable?
    
    func bind(resolvable: TableScrollResolvable) {
        self.resolvable = resolvable
    }
    
    func scrollTo(index: Int, position: TableScrollResolverPosition) {
        resolvable?.scrollTo(index: index, position: position)
    }
    
    func scrollToOffset(_ offset: CGPoint) {
        resolvable?.scrollToOffset(offset)
    }
    
}

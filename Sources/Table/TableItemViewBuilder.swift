import SwiftUI

public protocol TableItemViewBuilder {
    
    associatedtype Item
    
    func buildView(_ item: Item) -> AnyView
    
}

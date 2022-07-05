import SwiftUI

protocol TableItemViewBuilder {
    
    associatedtype Item
    
    static func buildView(_ item: Item) -> AnyView
    
}

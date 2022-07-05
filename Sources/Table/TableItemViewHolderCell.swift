import UIKit
import SwiftUI

final class TableItemViewHolderCell<Content: View>: UITableViewCell {
    
    weak var hosting: TableItemViewHolder<Content>?
    
    deinit {
        detach()
    }
        
    func attach(hosting: TableItemViewHolder<Content>,
                withParent parent: UIViewController) {
        
        detach()
                
        self.hosting = hosting
        
        hosting.willMove(toParent: parent)
        parent.addChild(hosting)
        hosting.didMove(toParent: parent)
        hosting.view.willMove(toSuperview: contentView)
        contentView.addSubview(hosting.view)
        hosting.view.didMoveToSuperview()
        
    }
    
    func detach() {
        hosting?.detach()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        hosting?.view.frame = contentView.bounds
    }
    
}
